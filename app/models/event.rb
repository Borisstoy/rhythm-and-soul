class Event < ApplicationRecord
  belongs_to :venue
  has_many :event_artists, dependent: :destroy
  has_many :artists, through: :event_artists
  has_many :users, through: :user_events
  has_many :user_events, dependent: :destroy
  acts_as_votable
  paginates_per 50

  def day
    self.date.strftime('%j')
  end

  def year
    self.date.strftime('%Y')
  end
end
