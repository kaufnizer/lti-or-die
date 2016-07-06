class ChangeUsersTokenCreateAtToTokenExpiresAt < ActiveRecord::Migration
  def change
    rename_column :users, :token_created_at, :token_expires_at
  end
end
