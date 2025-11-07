class AddAdminFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string
    add_column :users, :suspended, :boolean, default: false
  end
end
