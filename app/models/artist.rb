class Artist < ApplicationRecord
  has_many :event_artists, dependent: :destroy
  has_many :user_artists, dependent: :destroy
  has_many :events, through: :event_artists, dependent: :destroy
  has_many :artist_genres, dependent: :destroy
  has_many :genres, through: :artist_genres

  # TODO: use nested attributes
  def genre_list=(genre_names)
    genre_names.each do |genre_name|
      genres.find_or_create_by name: genre_name
    end
  end
end
