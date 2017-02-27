class ArtistsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @artist = Artist.find(params[:id])
  end

  private

  def artist_params
    params.require(:artist).permit(:name, :image)
  end
end
