class AddGenretoUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :genres, :string, array: true, default: []
  end
end
