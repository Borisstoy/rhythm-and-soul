class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @events = Event.find(params[:id])
  end
end
