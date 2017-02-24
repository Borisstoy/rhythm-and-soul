class Venue < ApplicationRecord
  has_many :events, dependent: :destroy

  geocoded_by :address
  #after_validation :geocode, if: :address_changed?
end
