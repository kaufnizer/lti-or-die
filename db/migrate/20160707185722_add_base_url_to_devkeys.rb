class AddBaseUrlToDevkeys < ActiveRecord::Migration
  def change
    add_column :devkeys, :base_url, :string
  end
end
