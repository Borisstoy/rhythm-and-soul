class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show, :scan_playlist ]

  def show
    @bookmarked_event = Event.where()
  end

  def scan_playlist
    #comment following line to run in controller
    #UNCOMMENT IF CRASH
#     SpotifyJob.perform_now(current_user.id)
#     #uncomment lines 13 and 14 to run in controller
#     # @user = current_user
#     # artists_image_and_genre
#     #uncomment line 16 to run ApiJob instead of Spotify job, in controller (bandsintown API call)
#     # perform
#     redirect_to user_path(current_user)
   
    SpotifyJob.perform_later(current_user.id)
    session[:scanning] = true

    #uncomment lines 13 and 14 to run in controller
    # @user = current_user
    # artists_image_and_genre
    redirect_to user_path(@user)
  end


  private

  def set_user
    @user = current_user
  end

  def perform
    artists = []
    artists_full_name = []
    User.first.artists.where(name: "Shifted").select(:name).each do |artist|
      @name = artist.name.dup
      artists << artist.name.gsub(" ", "").gsub("ë", "e").gsub("ö", "o").gsub("ä", "a")
      artists_full_name << @name
    end
    artists.each do |artist_name|
      result = bandsintown_api_client(artist_name.capitalize)
      build_event_index(result, artist_name)
    end
    artists_full_name.each do|artist_full_name|
      build_event_artists(artist_full_name)
    end

  end

  def bandsintown_api_client(artist_name)
    url = URI.escape "https://rest.bandsintown.com/artists/#{artist_name}/events?app_id=r%26s"
    return HTTParty.get(url)
  end

  def build_event_index(result, artist_name)
    i = 0
    unless result[i].nil? || result[i] == []
      until i == result.count
        unless result[i]["offers"].empty? || result[i]["offers"].nil? || result[i]["offers"] == [] || result[i].nil?
          @ticket = result[i]["offers"].first["url"]
          @venue = Venue.find_or_create_by(name: result[i]["venue"]["name"], latitude: result[i]["venue"]["latitude"].to_f, longitude: result[i]["venue"]["longitude"].to_f)
          if @venue.address.nil?
            @venue.address = Geocoder.address("#{result[i]["venue"]["latitude"]}, #{result[i]["venue"]["longitude"]}")
            @venue.save
          end
          @event = Event.find_or_create_by(name: artist_name, venue_id: @venue.id, date: result[i]["datetime"], ticket: @ticket)
        end
        i += 1
      end
    end
  end

  def build_event_artists(artists_full_name)
    @events = Event.where(name: artists_full_name.gsub(" ", "").gsub("ë", "e").gsub("ö", "o").gsub("ä", "a"))
    @events.each do |event|
      artists = Artist.where(name: artists_full_name)
      artists.each do |artist|
        raise
        event.artists << artist unless event.artists.include?(artist)
        artist.events << event unless artist.events.include?(event)
      end
    end
  end

  #uncomment all following private methods to run in controller
  # def playlists_ids_parsing(offset)
  #   url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists?limit=50&offset=#{offset}"
  #   playlists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
  #   @partial_playlist = JSON.parse(playlists_serialized.get)
  # end

  # def playlists_ids_storing
  #   playlists_ids_parsing(0)
  #   all_playlists = []
  #   @partial_playlist["items"].each do |playlist|
  #     all_playlists << playlist
  #   end

  #   if all_playlists.count % 50 != 0
  #     all_playlists
  #   else
  #     i = 50
  #     until all_playlists.count % 50 != 0
  #       playlists_ids_parsing(i)
  #       @partial_playlist["items"].each do |playlist|
  #         all_playlists << playlist
  #       end
  #       i += 50
  #     end
  #   end
  #   unwanted_playlists = all_playlists.map do |playlist|
  #     if playlist["owner"]["id"] != @user.spotify_id
  #       playlist
  #     end
  #   end
  #   unwanted_playlists.delete(nil)
  #   playlists = all_playlists - unwanted_playlists
  #   @playlists_ids = playlists.map do |playlist|
  #     playlist["id"]
  #   end
  #   return @playlists_ids
  # end

  # def get_tracks_artists
  #   tracks = []
  #   playlists_ids_storing.each do |playlist_id|
  #     url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{playlist_id}/tracks"
  #     tracks_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
  #     tracks << JSON.parse(tracks_serialized.get)
  #   end
  #   @names_and_ids = []
  #   @artists_names_and_ids = tracks.map do |playlist_tracks|
  #     playlist = playlist_tracks["items"]
  #     playlist.each do |track|
  #       unless track["track"].nil? || track["track"]["artists"][0]["uri"].nil?
  #         name_and_id = []
  #         track_artist_name = track["track"]["album"]["artists"][0]["name"]
  #         track_artist_id = track["track"]["album"]["artists"][0]["id"]
  #         name_and_id << track_artist_name
  #         name_and_id << track_artist_id
  #         @names_and_ids << name_and_id unless @names_and_ids.include?(name_and_id)
  #       end
  #     end
  #   end
  #   @names_and_ids
  # end

  # def artists_persistence
  #   get_tracks_artists
  #   @names_and_ids.each do |artist_array|
  #     artist = Artist.where(name: artist_array[0])
  #     unless artist.empty?
  #       unless @user.artists.include?(artist[0])
  #         new_user_artist = UserArtist.new()
  #         new_user_artist.artist = artist[0]
  #         new_user_artist.user = @user
  #         new_user_artist.save
  #       end
  #     else
  #       new_artist = Artist.new(name: artist_array[0])
  #       new_artist.save
  #       new_user_artist = UserArtist.new()
  #       new_user_artist.artist = new_artist
  #       new_user_artist.user = @user
  #       new_user_artist.save
  #     end
  #   end
  # end

  # def artists_image_and_genre
  #   artists_persistence
  #   # get_tracks_artists

  #   url = "https://api.spotify.com/v1/artists?ids="
  #   url_start_split = url.split("")
  #   i = 0
  #   j = 49
  #   @artists_images_genre = []
  #   while j < @names_and_ids.count + 50
  #     url_ids = []
  #     @names_and_ids[i..j].each do |artist|
  #       url_ids << artist[1]
  #       url_ids << ","
  #     end
  #     url = url_start_split + url_ids
  #     url.pop
  #     url = url.join("")
  #     artists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
  #     artists_parsed = JSON.parse(artists_serialized.get)
  #     artists_parsed["artists"].each { |artist| @artists_images_genre << artist }
  #     i += 50
  #     j += 50
  #   end
  #   # @artists_images_genre = @names_and_ids.map do |artist|
  #   #   url = "https://api.spotify.com/v1/artists/#{artist[1]}"
  #   #   artists_serialized = RestClient::Resource.new(url, headers: {accept: "application/json", authorization: "Bearer #{@user.auth_token}"})
  #   #   @artist = JSON.parse(artists_serialized.get)
  #   # end
  #   @artists_images_genre.each do |a|
  #     artist_to_update = Artist.where(name: a["name"])[0]
  #     artist_to_update.update(images: a["images"][0]["url"]) unless a["images"].empty? || Artist.where(name: a["name"])[0].nil? #Needs to be fixed, second condition shouldn't have to exist to prevent 'undefined method `genres'' error
  #       new_artist_genre = ArtistGenre.new()
  #     artist_genres = a["genres"]
  #     unless a["genres"].empty?
  #       artist_genres.each do |genre_name|
  #         genre = Genre.where(name: genre_name)
  #         if genre.exists?
  #           unless artist_to_update.nil? || artist_to_update.genres.include?(genre[0]) #Needs to be fixed, second condition shouldn't have to exist to prevent 'undefined method `genres'' error
  #             new_artist_genre = ArtistGenre.new()
  #             new_artist_genre.genre = genre[0]
  #             new_artist_genre.artist = artist_to_update
  #             new_artist_genre.save
  #           end
  #         else
  #           new_genre = Genre.new(name: genre_name)
  #           new_genre.save
  #           new_artist_genre = ArtistGenre.new()
  #           new_artist_genre.genre = new_genre
  #           new_artist_genre.artist = artist_to_update
  #           new_artist_genre.save
  #         end
  #       end
  #     end
  #   end
  # end
end
