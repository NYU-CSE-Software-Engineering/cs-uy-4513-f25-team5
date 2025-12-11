class AddPrimaryImageIdToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :primary_image_id, :string
  end
end
