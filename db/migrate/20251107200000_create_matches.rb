class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.integer :user_id, null: false
      t.integer :matched_user_id, null: false
      t.decimal :compatibility_score, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_index :matches, :user_id
    add_index :matches, :matched_user_id
    add_index :matches, [:user_id, :matched_user_id], unique: true
  end
end

