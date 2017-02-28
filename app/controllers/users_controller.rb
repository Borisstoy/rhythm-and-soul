class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show, :scan_playlist ]

  def show
    @bookmarked_event = Event.where()
  end

  def scan_playlist
    SpotifyJob.perform_later(current_user.id)
    session[:scanning] = true
    redirect_to user_path(@user)
  end


  private

  def set_user
    @user = current_user
  end
end
