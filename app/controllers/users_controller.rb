class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show ]

  def show
    @past_event = current_user.events.where("date < ?", Date.today)
  end



  private

  def set_user
    @user = current_user
  end
end
