class AddColumnToUserEvents < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_events, :user, foreign_key: true
    add_reference :user_events, :event, foreign_key: true
  end
end
