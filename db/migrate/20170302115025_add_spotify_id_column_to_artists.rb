class AddSpotifyIdColumnToArtists < ActiveRecord::Migration[5.0]
  def change
    add_column :artists, :spotify_id, :string
  end
end
