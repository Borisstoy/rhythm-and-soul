class Artist < ApplicationRecord
  has_many :event_artists, dependent: :destroy
  has_many :user_artists, dependent: :destroy
  has_many :events, through: :event_artists, dependent: :destroy
  has_many :artist_genres, dependent: :destroy
  has_many :genres, through: :artist_genres
end
