class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index

    @picked_start_date = params['start_date']
    @picked_end_date = params['end_date']
    @location = params['location']
    @events_filtered = []
    if current_user.nil?
      Artist.all.each do |artist|
        events = Event.where(name: artist.name)
        unless events.empty?
          events.each do |event|
            @events_filtered << event
          end
        end
      end
      @events_filtered.sort_by!(&:date)
    else
      current_user.artists.each do |artist|
        events = Event.where(name: artist.name)
        unless events.empty?
          events.each do |event|
            unless current_user.events.include?(event)
              user_event = UserEvent.new
              user_event.event = event
              user_event.user = current_user
              user_event.save
            end
          end
        end
      end
      current_user_events = current_user.events.order(date: :asc)
      @events_with_day = []
      current_user_events.each do |event|
        @events_filtered << event
      end
    end

    ########## Filters ##########
    # ARTISTS
    # filter for specific artist
    @events_filtered.select! do |event|
      if params['artist_filter'] == 'All'
        event
      elsif params['artist_filter']
        picked_artist = Artist.where(name: params['artist_filter'])
        event.name == picked_artist[0].name
      elsif params['artist_filter'].blank?
        event
      else
        event.name == 'Log in and scan your playlist!'
      end
    end
    # show in dropdown only artists if they have an event
    @user_artists_event = []
    if current_user.nil?
      Artist.all.each do |artist|
        @user_artists_event << artist unless artist.events.empty?
      end
    else
      current_user.artists.each do |artist|
        @user_artists_event << artist unless artist.events.empty?
      end
    end
    @user_artists_event.sort_by!(&:name)

    # LOCATION
    # Select venues according to location search
    unless params['location'].blank?
      searched_venues = Venue.near(params['location'], 100)
    else
      searched_venues = Venue.all
    end
    # Select the associated events
    @events_filtered.select! do |event|
      searched_venues.include?(event.venue)
    end



    # GENRE


    # DATE
    picked_start_date = DateTime.parse(params['start_date']).to_time unless params['start_date'].blank?
    picked_end_date = DateTime.parse(params['end_date']).to_time unless params['end_date'].blank?
    @events_filtered.select! do |event|
      if !params['start_date'].blank? && !params['end_date'].blank?
        event.date >= picked_start_date && event.date <= picked_end_date
      elsif params['start_date'].blank? && !params['end_date'].blank?
        event.date <= picked_end_date
      elsif !params['start_date'].blank? && params['end_date'].blank?
        event.date >= picked_start_date
      else
        true
      end
    end
    @events_markers = events_markers(@events_filtered)
    @current_user_liked_items = current_user.find_liked_items
  end

  def show
  end

  def bookmark
    @event = Event.find(params[:id])
    @event.liked_by current_user
    @current_user_liked_items = current_user.find_liked_items
    respond_to do |format|
      format.html { redirect_to events_path }
      format.js
    end
  end

  def remove_bookmark
    @event = Event.find(params[:id])
    @event.unliked_by current_user
    @current_user_liked_items = current_user.find_liked_items
    respond_to do |format|
      format.html { redirect_to events_path }
      format.js
    end
  end

  private

  def events_markers(events)
    venues_coordinates = []
    events_markers = []
    events.each do |event|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      venues_coordinates << position
      marker = {}
      marker[:venue_lat] = event.venue[:latitude]
      marker[:venue_lng] = event.venue[:longitude]
      marker[:infowindow] = "<div class='iw-container'><h3 class='iw-title'>#{event.venue.name}</h3><div class='iw-event'><h3>#{event.name}</h3><div>#{event.date.strftime('%d %b %Y')}</div></div></div>"
      events_markers << marker
    end

    #identify coordinates duplicated and add them to an array
    duplicate_coordinates = []
    venues_coordinates.each do |venue_coordinates|
      if venues_coordinates.count { |item| item == venue_coordinates } > 1 && !duplicate_coordinates.include?(venue_coordinates)
        duplicate_coordinates << venue_coordinates
      end
    end

    #iterate on the duplicate coordinate array to identify the events hash related / create a new element
    duplicate_coordinates.each do |coordinates|
      inloop_events_markers = events_markers.dup
      inloop_events_markers.keep_if { |marker| marker[:venue_lat] == coordinates[:lat] && marker[:venue_lng] == coordinates[:lng]}
      new_marker = {venue_lat: inloop_events_markers[0][:venue_lat],
        venue_lng: inloop_events_markers[0][:venue_lng],
        infowindow: ""
      }
      marker_infowindow_head = inloop_events_markers.first[:infowindow][/(<h3 class='iw-title'>).*?(<\/h3>)/]
      inloop_events_markers.each do |marker|
        new_marker[:infowindow] += marker[:infowindow].gsub(/(<h3 class='iw-title'>).*?(<\/h3>)/, "")
      end
      new_marker[:infowindow] = marker_infowindow_head + new_marker[:infowindow]
      events_markers.delete_if { |marker| marker[:venue_lat] == coordinates[:lat] && marker[:venue_lng] == coordinates[:lng]}
      events_markers << new_marker
    end
    return events_markers
  end
end
