class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_locale
  before_action :check_for_scanning

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || events_path
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def check_for_scanning
    @scanning = session[:scanning]
    session[:scanning] = nil # reset scanning flag
  end
end
