class CreateDevkeys < ActiveRecord::Migration
  def change
    create_table :devkeys do |t|
      t.string :domain
      t.string :id
      t.string :key
      t.string :uri

      t.timestamps null: false
    end
  end
end
