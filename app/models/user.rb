class User < ApplicationRecord
  has_many :user_artists, dependent: :destroy
  has_many :artists, through: :user_artists
  has_many :events, through: :artists
  has_many :user_events, dependent: :destroy
  has_many :genres, through: :artists
  acts_as_voter
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:spotify]
  after_save :async_update # Run on create & update

  def to_param
    spotify_id
  end

  private

  def async_update
    # ApiJob.perform_later
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, spotify_id: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.spotify_id = auth.uid
      user.email = auth.info.email
      auth.info.images[0].nil? ? user.image = 'http://hiphopmakers.com/wp-content/uploads/2014/03/wallpaper-443596.jpg' : user.image = auth.info.images[0].url
      user.name = auth.info.display_name
      user.auth_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.expires_at = Time.at(auth.credentials.expires_at)
      user.password = Devise.friendly_token[0,20]
    end
  end

  def user_params
    params.require(:user).permit(:email, :spotify_id)
  end
end
