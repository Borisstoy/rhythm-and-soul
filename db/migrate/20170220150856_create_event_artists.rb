class CreateEventArtists < ActiveRecord::Migration[5.0]
  def change
    create_table :event_artists do |t|
      t.references :artist, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
