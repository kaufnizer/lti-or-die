class AddCanvasApiTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :canvas_api_toke, :string
  end
end
