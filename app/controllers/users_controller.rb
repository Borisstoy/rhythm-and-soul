# require 'json'
# require 'open-uri'
# require 'rest-client'
require 'rspotify'
class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def show
    @user = User.find(params[:id])
    # RSpotify.authenticate("SPOTIFY_CLIENT_ID", "SPOTIFY_CLIENT_SECRET")
    # spotify_user = RSpotify::User.find(current_user.spotify_uid)
    # raise
    @toto = artists_persistence
  end

  private

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
    playlists_ids_storing[0..9].each do |playlist_id|
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
      tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      tracks << JSON.parse(tracks_serialized.get)
    end
    @artists_names = tracks.map do |track|
      track["items"][0]["track"]["album"]["artists"][0]["name"]
    end
  end

  def artists_persistence
    get_tracks_artists
    @artists_names.each do |artist|
      unless Artist.where(name: artist).exists?
        new_artist = Artist.new(name: artist)
        new_artist.save
        new_user_artist = UserArtist.new()
        new_user_artist.artist = new_artist
        new_user_artist.user = @user
        new_user_artist.save
      end
    end
  end
end
