class Genre < ApplicationRecord
  has_many :artists, through: :artist_genres, dependent: :nullify
  has_many :artist_genres, dependent: :destroy
end
