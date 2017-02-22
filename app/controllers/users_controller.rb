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
    @toto = artists_image_and_genre
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
    sleep(0.5)
    playlists_ids_storing[10..19].each do |playlist_id|
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
      tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      tracks << JSON.parse(tracks_serialized.get)
    end
    sleep(0.5)
    playlists_ids_storing[19..29].each do |playlist_id|
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
      tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      tracks << JSON.parse(tracks_serialized.get)
    end
    # sleep(1.minute)
    # playlists_ids_storing[29..39].each do |playlist_id|
    #   url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
    #   tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
    #   tracks << JSON.parse(tracks_serialized.get)
    # end
    @names_and_ids = []
    @artists_names_and_ids = tracks.map do |playlist_tracks|
      #must iterate on track["items"] to analyse all tracks of a playlist
      #replace 'tracks' by 'all_tracks' and 'track' by 'playlist_tracks'
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
    @names_and_ids.each do |artist|
      if Artist.where(name: artist[0]).exists?
        unless @user.artists.include?(Artist.where(name: artist[0])[0])
          new_user_artist = UserArtist.new()
          new_user_artist.artist = Artist.where(name: artist[0])[0]
          new_user_artist.user = @user
          new_user_artist.save
        end
      else
        new_artist = Artist.new(name: artist[0])
        new_artist.save
        new_user_artist = UserArtist.new()
        new_user_artist.artist = new_artist
        new_user_artist.user = @user
        new_user_artist.save
      end
      # unless Artist.where(name: artist[0]).exists?
      #   new_artist = Artist.new(name: artist[0])
      #   new_artist.save
      #   new_user_artist = UserArtist.new()
      #   new_user_artist.artist = new_artist
      #   new_user_artist.user = @user
      #   new_user_artist.save
      # else
      #   artist_to_link = Artist.where(name: artist[0])
      #   unless @user.artists.include?(artist_to_link)
      #     new_user_artist = UserArtist.new()
      #     new_user_artist.artist = artist_to_link
      #     new_user_artist.user = @user
      #     new_user_artist.save
      #   end
      # end
    end
  end

  def artists_image_and_genre
    artists_persistence
    get_tracks_artists
    raise
    @artists_images_genre = @names_and_ids.map do |artist|
      url = "https://api.spotify.com/v1/artists/#{artist[1]}"
      artists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
      @artist = JSON.parse(artists_serialized.get)
    end
    @artists_images_genre.each do |a|
      p a["name"]
      p Artist.where(name: a["name"])
      artist_to_update = Artist.where(name: a["name"])[0]
      artist_to_update.update(images: a["images"][0]["url"])
      artist_genres = a["genres"]
      artist_genres.each do |genre|
        unless Genre.where(name: genre).exists?
          new_genre = Genre.new()
        end
      end
      # p a["genres"]
      # p artist_to_update = Artist.where(name: a["name"])
      # p a["name"]
      # artist_to_update.update(images: a["images"][0]["url"])
    end
  end
end
