class ArtistsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :scan_playlist]

  def show
    @artist = Artist.find(params[:id])
  end
end
