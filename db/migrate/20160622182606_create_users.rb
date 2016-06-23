class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :primary_email
      t.string :canvas_user_id
      t.string :user_id

      t.timestamps null: false
    end
  end
end
