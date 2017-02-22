class User < ApplicationRecord
  has_many :user_artists
  has_many :artists, through: :user_artists
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:spotify]

  def self.from_omniauth(auth)
    where(provider: auth.provider, spotify_id: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.spotify_id = auth.uid
      user.email = auth.info.email
      user.image = auth.info.image
      user.name = auth.info.display_name
      user.auth_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.expires_at = Time.at(auth.credentials.expires_at)
      user.password = Devise.friendly_token[0,20]
    end
  end
end
