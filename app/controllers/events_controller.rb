class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @picked_start_date = params['start_date']
    @picked_end_date = params['end_date']
    picked_artist = Artist.where(name: params['artist_filter'])
    params[:location] == '' || params[:location].nil? ? @location = "Europe" : @location = params[:location]
    center_map_display(@location)

    ########## Filters ##########
    @events_filtered = user_signed_in? ? current_user.events.includes(:artists, :venue).where("date >= ?", Date.today) : Event.includes(:artists, :venue).where("date >= ?", Date.today)

    # LOCATION
    # Select venues according to location search
    @events_filtered = @events_filtered.where(venue: @searched_venues)

    # DATE
    @events_filtered = @events_filtered.where("date >= ?", @picked_start_date) unless @picked_start_date.blank?
    @events_filtered = @events_filtered.where("date < ?", @picked_end_date) unless @picked_end_date.blank?
    # ARTISTS
    # filter for specific artist
    @events_filtered = @events_filtered.where(artists: { name: params[:artist_filter]}) if !params[:artist_filter].blank? && params[:artist_filter] != 'All'

    # BOOKMARKED
    @current_user_liked_items = current_user.find_liked_items if user_signed_in?

    # MARKERS
    @events_markers = events_markers(@events_filtered)

    #KAMINARI
    # @events_filtered = @events_filtered.order(:date).page(params[:page]).per(25)
  end

  def show
    @artist = Artist.find(params[:id])
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
      format.html { redirect_to user_path }
      format.js
    end
  end

  private

  def center_map_display(location)
    center = Geocoder.search(location)
    bounds = center.first.geometry['bounds'] || Geocoder.search("Europe").first.geometry['bounds']
    box = [
      bounds['southwest']['lat'],
      bounds['southwest']['lng'],
      bounds['northeast']['lat'],
      bounds['northeast']['lng'],
    ]
    @searched_venues = Venue.within_bounding_box(box)
  end

  def events_markers(events)
    venues_coordinates = []
    events_markers = []
    events = events.to_a.sort_by! { |event| event.date }
    events.each do |event|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      venues_coordinates << position
      marker = {}
      marker[:venue_lat] = event.venue[:latitude]
      marker[:venue_lng] = event.venue[:longitude]

      marker[:infowindow] = "
      <div class='iw-container event'>
        <h3 class='iw-title'>#{event.venue.name}</h3>
        <div class='iw-event'>
          <div>
            <h3>#{event.artists.first.name}</h3>
            <div>
              #{event.date.strftime('%d %b %Y')}
            </div>
          </div>
          <div class='iw-bookmark' id='iw_event_#{event.id}'>
            #{ ApplicationController.render(partial: 'events/bookmark', locals: { event: event, current_user: current_user, current_user_liked_items: @current_user_liked_items })}
          </div>
        </div>
      </div>"
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
