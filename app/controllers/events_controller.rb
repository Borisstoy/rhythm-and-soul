class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    @events = Event.all
    @venues = Venue.where.not(latitude: nil, longitude: nil)
    @hash = Gmaps4rails.build_markers(@venues) do |venue, marker|
      marker.lat venue.latitude
      marker.lng venue.longitude


    artist_name = "pnl"
    country_name = "France"

    url = "https://rest.bandsintown.com/artists/#{artist_name}/events?app_id=r%26s"
    result_serialized = open(url).read
    result = JSON.parse(result_serialized)
    i = 0
      until i == 10
          time = result[i]["datetime"]
          time = Date.parse( time.gsub(/, */, '-') ).strftime("%m/%d/%Y")
          venue_name = result[i]["venue"]["name"]
          city = result[i]["venue"]["city"]
          venue_country = result[i]["venue"]["country"]
          latitude = result[i]["venue"]["latitude"]
          longitude = result[i]["venue"]["longitude"]
          i += 1
          if country_name == venue_country
            @lineup = result[i]["lineup"]
            @venue_name = venue_name
            @venue_country = venue_country
            @time = time
            result[i]["offers"].each {|t| p t["url"]}
            @latitude = latitude
            @longitude = longitude
          end
      end

    end
  end

  def show
  end
end
