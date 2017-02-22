class AddTicketsToEvents < ActiveRecord::Migration[5.0]
  def change
        add_column :events, :ticket, :string
  end
end
