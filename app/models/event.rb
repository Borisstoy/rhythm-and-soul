class Event < ApplicationRecord
  belongs_to :venue
  has_many :event_artists
  has_many :artists, through: :event_artists, dependent: :destroy
  has_many :users, through: :user_events
  acts_as_votable
end
