class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    @events_filtered = []
    Artist.all.each do |artist|
      @events = Event.where(name: artist.name)
      unless @events.nil?
        @events.each do |event|
        @events_filtered << event
        end
      end
      @markers_hash = markers_hash(@events_filtered)
    end
  end

  def show
  end

  def bookmark
    @event = Event.find(params[:id])
    @event.liked_by current_user
    redirect_to @event
  end

  def remove_bookmark
    @event = Event.find(params[:id])
    @event.downvote_from current_user
    redirect_to @event
  end

  private


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

