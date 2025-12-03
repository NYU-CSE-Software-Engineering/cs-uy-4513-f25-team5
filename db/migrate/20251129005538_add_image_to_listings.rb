class AddImageToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :image_base64, :text
    add_column :listings, :filename, :string
  end
end
