class AddRefreshTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :canvas_api_refresh_token, :string
  end
end
