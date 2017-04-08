# frozen_string_literal: true

class SpotifyWorker
  DEFAULT_QUERY_PARAMS ||= { offset: 0, limit: 50 }.freeze

  include Sidekiq::Worker
  include SidekiqStatus::Worker

  sidekiq_options retry: false

  def perform(current_user_id)
    @user = User.find current_user_id
    self.total = 100

    fetch_playlists
    at 20
    fetch_tracks
    at 70
    find_or_create_artists
    at 80
    sync_artists
    at 90
    link_artists_to_user
    at 100
  end

  private

  # specific

  def fetch_playlists
    log 'fetching playlists'
    @playlists = fetch_records path: user_playlists_request_path
  end

  def fetch_tracks
    log 'fetching tracks'
    @tracks = owned_playlists.flat_map do |playlist|
      uri = with_query_params playlist.dig :tracks, :href
      fetch_records uri: uri
    end
  end

  # TODO: eager-load existing artists
  def find_or_create_artists
    log 'creating artist records'
    @artist_by_spotify_id = @tracks.each_with_object({}) do |track, memo|
      artist_spotify_id = track.dig :track, :album, :artists, 0, :id
      memo[artist_spotify_id] ||= Artist.find_or_create_by spotify_id: artist_spotify_id
    end
  end

  # TODO: skip artists which have been updated recently
  def sync_artists
    log 'syncing artist records'
    @artist_by_spotify_id.keys.each_slice(50) do |ids|
      uri = request_uri path: 'v1/artists', query: 'ids=' + ids.join(',')
      data = fetch(uri)[:artists] || []
      data.each { |record| update_artist record }
    end
  end

  def link_artists_to_user
    log 'linking artists to user'
    @user.artists += @artist_by_spotify_id.values
  end

  def update_artist(data)
    id, name, genres, images = data.values_at :id, :name, :genres, :images

    @artist_by_spotify_id[id]
      .update name: name,
              genre_list: genres,
              images: images.dig(0, :url)
  end

  def user_playlists_request_path
    [ 'v1',
      'users',
      @user.spotify_id,
      'playlists'
    ].join('/')
  end

  def owned_playlists
    @playlists.select do |playlist|
      playlist.dig(:owner, :id) == @user.spotify_id
    end
  end

  # generic

  def request_uri(path:, query: DEFAULT_QUERY_PARAMS)
    query_string = query.is_a?(String) ? query : query.to_query
    URI::HTTPS
      .build host: 'api.spotify.com',
             path: '/' + path,
             query: query_string
  end

  def with_query_params(uri_string, params = {})
    URI.parse(uri_string).tap do |uri|
      uri.query =
        URI
          .decode_www_form(uri.query.to_s)
          .to_h
          .reverse_merge(DEFAULT_QUERY_PARAMS)
          .merge(params)
          .to_query
    end
  end

  def fetch_records(uri: nil, path: nil)
    uri ||= request_uri path: path

    [].tap do |results|
      loop do
        data = fetch uri
        results.concat data[:items] || []
        break unless uri = data[:next]
      end
    end
  end

  def fetch(uri)
    log "Sending request at #{uri}"
    response = RestClient::Resource
                 .new(uri.to_s,
                      headers: { accept: 'application/json',
                                 authorization: "Bearer #{@user.auth_token}"
                               })
                 .get

    JSON
      .parse(response)
      .with_indifferent_access
  end

  def log(message)
    Rails.logger.info "SpotifyWorker: #{message}"
  end
end
