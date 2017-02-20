class Event < ApplicationRecord
  belongs_to :venue
  has_many :event_artists
end
