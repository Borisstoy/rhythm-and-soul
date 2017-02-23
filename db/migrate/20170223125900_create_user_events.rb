class CreateUserEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :user_events do |t|

      t.timestamps
    end
  end
end
