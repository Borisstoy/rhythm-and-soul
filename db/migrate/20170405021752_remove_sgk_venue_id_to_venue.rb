class RemoveSgkVenueIdToVenue < ActiveRecord::Migration[5.0]
  def change
    remove_column :venues, :sgkvenueid
  end
end
