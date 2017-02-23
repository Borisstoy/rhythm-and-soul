class ApiJob < ApplicationJob
  queue_as :default

  def perform
    artists = ["drake", "pnl", "vianney"]
    artists.each do |artist_name|
    result = bandsintown_api_client(artist_name)
    build_event_index(result, artist_name)
  end
  end

  def bandsintown_api_client(artist_name)
    url = "https://rest.bandsintown.com/artists/#{artist_name}/events?app_id=r%26s"
    result_serialized = open(url).read
    result = JSON.parse(result_serialized)
  end

  def build_event_index(result, artist_name)
    i = 0
    until i == result.count
      unless result[i]["offers"].empty?
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

