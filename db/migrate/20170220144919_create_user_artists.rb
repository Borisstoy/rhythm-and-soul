class CreateUserArtists < ActiveRecord::Migration[5.0]
  def change
    create_table :user_artists do |t|
      t.references :user, foreign_key: true
      t.references :artist, foreign_key: true

      t.timestamps
    end
  end
end
