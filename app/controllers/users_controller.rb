class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show, :scan_playlist ]

  def show
    @past_event = current_user.events.includes(:artists, :venue).where("date < ?", Date.today)
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
