class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    artist_name = "louiseroam"
    country_name = "france"
    result = bandsintown_api_client(artist_name, country_name)
    build_event_index(result, artist_name, country_name)
  end

 private

 def bandsintown_api_client(artist_name, country_name)
  url = "https://rest.bandsintown.com/artists/#{artist_name}/events?app_id=r%26s"
  result_serialized = open(url).read
  result = JSON.parse(result_serialized)
 end

def build_event_index(result, artist_name, country_name)
    Event.destroy_all
    @hash = {}
    i = 0
    until i == 10 || result[i].nil?
      city = result[i]["venue"]["city"]
      venue_country = result[i]["venue"]["country"]
      if country_name.capitalize == venue_country
        # @lineup = result[i]["lineup"]
        result[i]["offers"].each {|t| @ticket = t["url"]}
        @venue = Venue.create(name: result[i]["venue"]["name"], latitude: result[i]["venue"]["latitude"], longitude: result[i]["venue"]["longitude"])
        @venue.address = Geocoder.address("#{result[i]["venue"]["latitude"]}, #{result[i]["venue"]["longitude"]}")
        @venue.save
        @event = Event.create(name: artist_name, venue_id: @venue.id, date: result[i]["datetime"])
      end
      i += 1
    end
    @events = Event.all
    @hash = Gmaps4rails.build_markers(@events) do |event, marker|
        # positions << position
        marker.lat event.venue.latitude
        marker.lng event.venue.longitude
    end
  end

end

