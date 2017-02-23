class Artist < ApplicationRecord
  has_many :event_artists
  has_many :user_artists, dependent: :destroy
  has_many :users, through: :user_artists
  has_many :events, through: :event_artists
  has_many :genres, through: :artist_genres, dependent: :nullify
  has_many :artist_genres, dependent: :destroy
end
