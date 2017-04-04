class AddSgkVenueIdToVenues < ActiveRecord::Migration[5.0]
  def change
    add_column :venues, :sgkvenueid, :integer
  end
end
