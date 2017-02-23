class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show ]

  def show
    # @toto = artists_image_and_genre
  end

  def scan_playlist
    @user = current_user
    artists_image_and_genre
    redirect_to root_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def playlists_ids_parsing(offset)
    url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists?limit=50&offset=#{offset}"
    playlists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
    @partial_playlist = JSON.parse(playlists_serialized.get)
  end

  def playlists_ids_storing
    playlists_ids_parsing(0)
    playlists = []
    @partial_playlist["items"].each do |playlist|
      playlists << playlist
    end

    if playlists.count % 50 != 0
      return playlists
    else
      i = 50
      until playlists.count % 50 != 0
        playlists_ids_parsing(i)
        @partial_playlist["items"].each do |playlist|
          playlists << playlist
        end
        i += 50
      end
    end
    playlists.each do |playlist|
      playlists.delete(playlist) if playlist["owner"]["id"] != @user.spotify_id
    end
    @playlists_ids = playlists.map do |playlist|
      playlist["id"]
    end
    @playlists_ids
  end

  def get_tracks_artists
    tracks = []
    # i = 0
    # j = 1
    # k = playlists_ids_storing.count
    # until j > k - 1
    #   playlists_ids_storing[i..j].each do |playlist_id|
    #     url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
    #     tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
    #     tracks << JSON.parse(tracks_serialized.get)
    #   end
    #   i += 1
    #   j += 1
    #   sleep(5)
    # end
    playlists_ids_storing[5..6].each do |playlist_id|
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
      tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      tracks << JSON.parse(tracks_serialized.get)
    end
    @names_and_ids = []
    @artists_names_and_ids = tracks.map do |playlist_tracks|
      playlist = playlist_tracks["items"]
      playlist.each do |track|
        unless track["track"].nil?
          name_and_id = []
          track_artist_name = track["track"]["album"]["artists"][0]["name"]
          track_artist_id = track["track"]["album"]["artists"][0]["id"]
          name_and_id << track_artist_name
          name_and_id << track_artist_id
          @names_and_ids << name_and_id unless @names_and_ids.include?(name_and_id)
        end
      end
    end
    @names_and_ids
  end

  def artists_persistence
    get_tracks_artists
    @names_and_ids.each do |artist_array|
      artist = Artist.where(name: artist_array[0])
      if Artist.where(name: artist[0]).exists?
        unless @user.artists.include?(artist[0])
          new_user_artist = UserArtist.new()
          new_user_artist.artist = artist[0]
          new_user_artist.user = @user
          new_user_artist.save
        end
      else
        new_artist = Artist.new(name: artist_array[0])
        new_artist.save
        new_user_artist = UserArtist.new()
        new_user_artist.artist = new_artist
        new_user_artist.user = @user
        new_user_artist.save
      end
    end
  end

  def artists_image_and_genre
    artists_persistence
    get_tracks_artists
    @artists_images_genre = @names_and_ids.map do |artist|
      url = "https://api.spotify.com/v1/artists/#{artist[1]}"
      artists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      @artist = JSON.parse(artists_serialized.get)
    end
    @artists_images_genre.each do |a|
      artist_to_update = Artist.where(name: a["name"])[0]
      artist_to_update.update(images: a["images"][0]["url"])
      artist_genres = a["genres"]
      artist_genres.each do |genre_name|
        genre = Genre.where(name: genre_name)
        if genre.exists?
          unless artist_to_update.genres.include?(genre[0])
            new_artist_genre = ArtistGenre.new()
            new_artist_genre.genre = genre[0]
            new_artist_genre.artist = artist_to_update
            new_artist_genre.save
          end
        else
          new_genre = Genre.new(name: genre_name)
          new_genre.save
          new_artist_genre = ArtistGenre.new()
          new_artist_genre.genre = new_genre
          new_artist_genre.artist = artist_to_update
          new_artist_genre.save
        end
      end
    end
  end
end
