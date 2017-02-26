class Genre < ApplicationRecord
  has_many :artists, through: :artist_genres
  has_many :artist_genres, dependent: :destroy
end
