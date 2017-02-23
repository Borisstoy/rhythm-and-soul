class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    artist_name = "pnl"
    country_name = "France"
    result = bandsintown_api_client(artist_name, country_name)
    build_event_index(result, artist_name, country_name)
    @events = Event.where(name: artist_name)
    @markers_hash = markers_hash(@events)
  end

  def show
  end

  private

   def bandsintown_api_client(artist_name, country_name)
    url = "https://rest.bandsintown.com/artists/#{artist_name}/events?app_id=r%26s"
    result_serialized = open(url).read
    result = JSON.parse(result_serialized)
   end

  def build_event_index(result, artist_name, country_name)
      @hash = {}
      i = 0
      until i == 100 || result[i].nil?
        city = result[i]["venue"]["city"]
        venue_country = result[i]["venue"]["country"]
        if country_name.capitalize == venue_country
          # @lineup = result[i]["lineup"]
          result[i]["offers"].each {|t| @ticket = t["url"]}
          @venue = Venue.new(name: result[i]["venue"]["name"], latitude: result[i]["venue"]["latitude"], longitude: result[i]["venue"]["longitude"])
          @venue.address = Geocoder.address("#{result[i]["venue"]["latitude"]}, #{result[i]["venue"]["longitude"]}")
          @venue.save unless Venue.where(name: result[i]['venue']['name']).exists?
          @event = Event.create(name: artist_name, venue_id: @venue.id, date: result[i]["datetime"], ticket: @ticket)
        end
        i += 1
      end
    end


  def markers_hash(events)
    venues_coordinates = []
    markers_hash = Gmaps4rails.build_markers(events) do |event, marker|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      venues_coordinates << position
      marker.lat event.venue.latitude
      marker.lng event.venue.longitude
      marker.picture url: ActionController::Base.helpers.asset_path("map_marker.png"), width: 36, height: 36
      marker.infowindow "<div class='iw-container'><h3 class='iw-title'>#{event.venue.name}</h3><div class='iw-event'><h3>#{event.name}</h3><div>#{event.date.strftime('%d %b %Y')}</div></div></div>"
    end

    #identify coordinates duplicated and add them to an array
    duplicate_coordinates = []
    venues_coordinates.each do |venue_coordinates|
      !duplicate_coordinates.include?(venue_coordinates)
      if venues_coordinates.count { |item| item == venue_coordinates } > 1 && !duplicate_coordinates.include?(venue_coordinates)
        duplicate_coordinates << venue_coordinates
      end
    end
    #iterate on the duplicate coordinate array to identify the events hash related / create a new element
    duplicate_coordinates.each do |coordinates|
      inloop_markers_hash = markers_hash.dup
      inloop_markers_hash.keep_if { |marker| marker[:lat] == coordinates[:lat] && marker[:lng] == coordinates[:lng]}
      new_marker = {lat: inloop_markers_hash[0][:lat],
        lng: inloop_markers_hash[0][:lng],
        picture: inloop_markers_hash[0][:picture],
        infowindow: ""
      }
      marker_infowindow_head = inloop_markers_hash.first[:infowindow][/(<h3 class='iw-title'>).*?(<\/h3>)/]
      inloop_markers_hash.each do |marker|
        new_marker[:infowindow] += marker[:infowindow].gsub(/(<h3 class='iw-title'>).*?(<\/h3>)/, "")
      end
      new_marker[:infowindow] = marker_infowindow_head + new_marker[:infowindow]
      markers_hash.delete_if { |marker| marker[:lat] == coordinates[:lat] && marker[:lng] == coordinates[:lng]}
      markers_hash << new_marker
    end
    return markers_hash
  end
end

