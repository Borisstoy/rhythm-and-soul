class Genre < ApplicationRecord
  has_many :artists, through: :artist_genres
end
