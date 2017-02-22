class CreateArtistGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :artist_genres do |t|
      t.references :artist, foreign_key: true
      t.references :genre, foreign_key: true

      t.timestamps
    end
  end
end
