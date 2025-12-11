class CreateLikedListings < ActiveRecord::Migration[7.1]
  def change
    create_table :liked_listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true

      t.timestamps
    end
    
    # Ensure a user can only like a listing once
    add_index :liked_listings, [:user_id, :listing_id], unique: true
  end
end
