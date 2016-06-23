class ChangeUsersCanvasApiTokeToCanvasApiToken < ActiveRecord::Migration
  def change
    rename_column :users, :canvas_api_toke, :canvas_api_token
  end
end
