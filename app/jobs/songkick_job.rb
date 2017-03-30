class SongkickJob < ApplicationJob
  queue_as :default

  def perform
    artists = []
    artists_full_name = []
    Artist.all.select(:name).each do |artist|
      @name = artist.name.dup
      artists << artist.name.gsub(" ", "").gsub("ë", "e").gsub("ö", "o").gsub("ä", "a") unless artist.name == "Various Artists"
      artists_full_name << @name
    end

    artists.each do |artist_name|
      artist_arr = songkick_artist_id(artist_name)
      artists_results = artist_arr["resultsPage"]["results"]
      unless artists_results == [] || artists_results.nil? || artists_results.blank?
        id = artist_arr["resultsPage"]["results"]["artist"][0]["id"]
      end
      artists_calendars = songkick_artist_event(id)
      artists_calendars_results = artists_calendars["resultsPage"]["results"]
      unless artists_calendars_results.blank? || artists_calendars_results.nil? || artists_calendars_results == []
        build_event_index(artists_calendars, artist_name)
      end
    end

    artists_full_name.each do |artist_full_name|
      build_event_artists(artist_full_name)
    end
  end

  # Gets artists ids
  def songkick_artist_id(artist_name)
    url = URI.escape "http://api.songkick.com/api/3.0/search/artists.json?query=#{artist_name}&apikey=#{ENV["SONGKICK_API_KEY"]}"
    return HTTParty.get(url)
  end

  # Gets artists calendars based on artists ids
  def songkick_artist_event(artist_id)
    url = URI.escape "http://api.songkick.com/api/3.0/artists/#{artist_id}/calendar.json?apikey=#{ENV["SONGKICK_API_KEY"]}"
    return HTTParty.get(url)
  end

  # Loops through each artists_calendars until there's no event
  def build_event_index(artists_calendars, artist_name)
    artist_events = artists_calendars["resultsPage"]["results"]["event"]
    events_count = 0
    unless artist_events.nil? || artist_events == [] || artists_calendars.nil?
      until events_count == artist_events.count
        @venue_name = artist_events[events_count]["venue"]["displayName"]
        @venue_name = artist_events[events_count]["venue"]["displayName"]
        @venue_ticket = artist_events[events_count]["uri"]
        @venue_lat = artist_events[events_count]["location"]["lat"]
        @venue_lng = artist_events[events_count]["location"]["lng"]
        @event_date = artist_events[events_count]["start"]["date"]
        # TODO
        # if event already exists, check duplicate with date
        # if event doesn't exist, create
        @venue = Venue.find_or_create_by(name: @venue_name, latitude: @venue_lat.to_f, longitude: @venue_lng.to_f)
        if @venue.address.nil?
          @venue.address = Geocoder.address("#{@venue_lat}, #{@venue_lng}")
          @venue.save
        end
        @event = Event.find_or_create_by(name: artist_name, venue_id: @venue.id, date: @event_date, ticket: @venue_ticket)
        events_count += 1
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
