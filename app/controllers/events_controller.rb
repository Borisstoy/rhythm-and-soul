class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @picked_start_date = params[:start_date]
    @picked_end_date = params[:end_date]
    @selected_artist = params[:artist_filter]
    @selected_genre = params[:genre_filter]
    @picked_location = params[:location]

    center_map
    build_events
    location_filter
    date_filter
    artists_filter
    genres_filter
    markers
    liked_events
    # pagination
  end

  def center_map
     @location = params[:location].presence || "Canada"
    center_map_display(@location)
  end

  def build_events
    @events_filtered =
      (user_signed_in? ? current_user.events : Event)
        .includes(:artists, :venue)
        .where("date >= ?", Date.today)
        .order(:date)
  end

  def location_filter
    @events_filtered = @events_filtered.where(venue: @searched_venues)
  end

  def date_filter
    @events_filtered = @events_filtered.where("date >= ?", @picked_start_date) unless @picked_start_date.blank?
    @events_filtered = @events_filtered.where("date < ?", @picked_end_date) unless @picked_end_date.blank?
  end

  def artists_filter
    @events_filtered = @events_filtered.where(artists: { name: @selected_artist }) if !@selected_artist .blank? && @selected_artist  != 'All artists'
  end

  def genres_filter
    if (!@selected_genre.blank? && @selected_genre != 'All genres') && (@selected_artist != 'All artists' || @selected_artist == 'All artists')
      @events_filtered = @events_filtered
      .includes(artists: :genres)
      .where(genres: { name: @selected_genre.downcase})
    end
  end

  def markers
    @events_markers = events_markers(@events_filtered)
  end

  def liked_events
    @current_user_liked_items = current_user.find_liked_items if user_signed_in?
  end

  # def pagination
  #   @events_filtered = @events_filtered.page(1).per(20)
  #   respond_to do |format|
  #     format.html { render 'index' }
  #     format.js   { render 'infinite_scroll_index' }
  #   end
  # end

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
      format.html { redirect_to user_path(current_user) }
      format.js
    end
  end

  private

  def center_map_display(location)
    center = Geocoder.search(location)
    bounds = center.first.geometry['bounds'] || Geocoder.search("Canada").first.geometry['bounds']
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
    # events = events.to_a.sort_by! { |event| event.date }
    events.each do |event|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      venues_coordinates << position
      marker = {}
      marker[:venue_lat] = event.venue[:latitude]
      marker[:venue_lng] = event.venue[:longitude]
      marker[:infowindow] = render_to_string(partial: "infowindow.html.erb", formats: [:html], layout: false, locals: {current_user: current_user, current_user_liked_items: @current_user_liked_items, event: event}, cache: true)
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
