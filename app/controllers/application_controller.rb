class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_locale

  def after_sign_in_path_for(resource)
    user_path(resource)
    # request.env['omniauth.origin'] || stored_location_for(resource) || user_path
  end

  def default_url_options
    {
      host: ENV['HOST'] || 'localhost:3000',
      locale: I18n.locale == I18n.default_locale ? nil : I18n.locale
    }
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
