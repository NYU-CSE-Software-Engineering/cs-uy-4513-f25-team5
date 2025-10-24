class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :display_name
      t.text :bio
      t.integer :budget
      t.string :preferred_location
      t.string :sleep_schedule
      t.string :pets
      t.string :housing_status
      t.string :contact_visibility
    end
  end
end
