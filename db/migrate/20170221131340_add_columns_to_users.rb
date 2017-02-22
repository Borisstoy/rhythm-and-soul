class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :image, :string
    add_column :users, :provider, :string
    add_column :users, :spotify_id, :string
    add_column :users, :token, :string
    add_column :users, :token_expiry, :datetime
    add_column :users, :name, :string
  end
end
