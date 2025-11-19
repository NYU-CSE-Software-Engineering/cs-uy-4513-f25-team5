class CreateActiveMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :active_matches do |t|
      t.references :user_one, null: false, foreign_key: { to_table: :users }
      t.references :user_two, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false

      t.timestamps
    end

    add_index :active_matches, [:user_one_id, :user_two_id], unique: true
  end
end

