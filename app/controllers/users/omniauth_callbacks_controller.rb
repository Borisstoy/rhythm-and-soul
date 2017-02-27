require 'httparty'
class Users::OmniauthCallbacksController <  Devise::OmniauthCallbacksController
  def spotify_auth_token
    @user.auth_token
  end

  def token_expires_at
    @user.expires_at
  end

  def spotify_refresh_token
    @user.refresh_token
  end

  def spotify
    @user = User.from_omniauth(request.env["omniauth.auth"])

    self.validate_spotify_auth_token if self.spotify_auth_token.present?
    config = {
     :access_token => self.spotify_auth_token,  # initialize the client with an access token to perform authenticated calls
     :raise_errors => true,  # choose between returning false or raising a proper exception when API calls fails

     # Connection properties
     :retries       => 0,    # automatically retry a certain number of times before returning
     :read_timeout  => 10,   # set longer read_timeout, default is 10 seconds
     :write_timeout => 10,   # set longer write_timeout, default is 10 seconds
     :persistent    => false # when true, make multiple requests calls using a single persistent connection. Use +close_connection+ method on the client to manually clean up sockets
    }
    @client ||= ::Spotify::Client.new(config)

    SpotifyJob.perform_later(@user.id)
    session[:scanning] = true
    sign_in_and_redirect @user
  end

  def validate_spotify_auth_token
    if Time.now > self.token_expires_at
      encoded_auth = Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}")
      request = { :body => { "grant_type" => "refresh_token", "refresh_token" => self.spotify_refresh_token } ,
                    :headers => { "Authorization" => "Basic #{encoded_auth}" }
                  }
      response = HTTParty.post("https://accounts.spotify.com/api/token?refresh_token", request)
      @user.update(:auth_token => response["access_token"], :expires_at => Time.now + response["expires_in"])
    end
  end
end
