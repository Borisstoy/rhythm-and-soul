class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: [ :show ]
  protect_from_forgery except: :scan_playlist

  def show
    @past_event = @user.events.where("date < ?", Date.today)
  end

  def scan_playlist
    user = User.find(current_user.id)
    @job_id = SpotifyWorker.perform_async(current_user.id)
    respond_to do |format|
      format.js
    end
  end

  def percentage_done
    job_id = params[:job_id] # grabbing the job_id from params

    # Using the sidekiq_status gem to query the background job for progress information.
    container = SidekiqStatus::Container.load(job_id)
    # I'm asking the background job how far along it is in the process
    @pct_complete = container.pct_complete

    respond_to do |format|
      format.json {
        render :json => {
          :percentage_done => @pct_complete, # responding with json with the percent complete data
        }
      }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
