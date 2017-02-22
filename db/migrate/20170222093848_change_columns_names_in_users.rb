class ChangeColumnsNamesInUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :token, :auth_token
    rename_column :users, :token_expiry, :expires_at
  end
end
