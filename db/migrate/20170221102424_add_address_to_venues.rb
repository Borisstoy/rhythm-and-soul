class AddAddressToVenues < ActiveRecord::Migration[5.0]
  def change
    add_column :venues, :address, :string
  end
end
