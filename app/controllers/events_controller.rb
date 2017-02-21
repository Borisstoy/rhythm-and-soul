class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  def index
    @events = Event.all
    @venues = Venue.where.not(latitude: nil, longitude: nil)
    # positions = []
    @hash = Gmaps4rails.build_markers(@events) do |event, marker|
      position = { lat: event.venue.latitude, lng: event.venue.longitude }
      # positions << position
      marker.lat event.venue.latitude
      marker.lng event.venue.longitude
      marker.picture url: ActionController::Base.helpers.asset_path("map_marker.png"), width: 15, height: 15
      marker.infowindow "<div><strong>#{event.venue.name}</strong></div><div>#{event.name}</div><div>#{event.date.strftime('%d %b %Y')}</div>"
    end
    # supprimer les marqueurs doublons (même lat et même lng)
    # enrichir l'infowindow du marqueur restant avec le nom des events des marqueurs supprimés
    #


    # hash_duplicate = @hash.dup
    # hash_duplicate.each do |hash|
    #   if hash_duplicate.count(hash) > 1
    #     my_first_hash = @hash.find { |item| item == hash }
    #     # autres markers à virer
    #     duplicates = hash_duplicate.select { |h| h == hash }
    #     my_first_hash[infowindow] += "<div>#{venue.name}</div>"
    #   else
    #   end
    # end
  end

  def show
  end
end
