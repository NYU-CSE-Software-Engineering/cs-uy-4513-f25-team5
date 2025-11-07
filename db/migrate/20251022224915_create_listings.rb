class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :city
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
