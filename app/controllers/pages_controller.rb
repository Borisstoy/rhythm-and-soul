class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  layout "home", only: [ :home ]

  def home
    session[OmniAuth::Strategies::Spotify::FORCE_APPROVAL_KEY] = true
  end
end
