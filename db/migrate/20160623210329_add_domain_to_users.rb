class AddDomainToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_requested_from, :string
  end
end
