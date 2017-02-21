class Event < ApplicationRecord
  belongs_to :venue
  has_many :event_artists
  has_many :artists, through: :event_artists
end
