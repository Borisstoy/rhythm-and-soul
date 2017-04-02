class Genre < ApplicationRecord
  has_many :artists, through: :artist_genres
  has_many :artist_genres, dependent: :destroy
  has_many :events, through: :artists
  has_many :users, through: :artists
end
