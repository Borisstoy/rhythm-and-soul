class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    @events = Event.all
    venues_coordinates = []
    markers_hash = Gmaps4rails.build_markers(@events) do |event, marker|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      venues_coordinates << position
      marker.lat event.venue.latitude
      marker.lng event.venue.longitude
      marker.picture url: ActionController::Base.helpers.asset_path("map_marker.png"), width: 36, height: 36
      marker.infowindow "<strong>#{event.venue.name}</strong><div>#{event.name}</div><div>#{event.date.strftime('%d %b %Y')}</div>"
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
      marker_infowindow_head = inloop_markers_hash.first[:infowindow][/(<strong>).*(<\/strong>)/]
      inloop_markers_hash.each do |marker|
        new_marker[:infowindow] += marker[:infowindow].gsub(/(<strong>).*(<\/strong>)/, "")
      end
      new_marker[:infowindow] = marker_infowindow_head + new_marker[:infowindow]
      markers_hash.delete_if { |marker| marker[:lat] == coordinates[:lat] && marker[:lng] == coordinates[:lng]}
      markers_hash << new_marker
    end

    @curated_event_hash = markers_hash.dup
  end

  def show
  end
end

