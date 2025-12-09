class CreateSearchHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :search_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :city
      t.decimal :min_price
      t.decimal :max_price
      t.string :keywords

      t.timestamps
    end

    add_index :search_histories, [:user_id, :created_at]
  end
end
