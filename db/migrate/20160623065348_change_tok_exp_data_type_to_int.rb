class ChangeTokExpDataTypeToInt < ActiveRecord::Migration
  def change
      change_column :users, :token_expires_at, 'integer USING CAST(token_expires_at AS integer)'
  end
end
