
class ApiJob < ApplicationJob
  queue_as :default

  def perform
    artists = []
    artists_full_name = []
    Artist.all.select(:name).each do |artist|
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
        unless event.artists.include?(artist)
        event.artists << artist
        end
      end
    end

  end


end

