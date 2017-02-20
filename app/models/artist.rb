class Artist < ApplicationRecord
  has_many :event_artists
  has_many :user_artists
end
