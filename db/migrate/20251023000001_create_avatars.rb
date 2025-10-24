class CreateAvatars < ActiveRecord::Migration[7.1]
  def change
    create_table :avatars do |t|
      t.references :user, null: false, foreign_key: true
      t.text :image_base64, null: false
      t.string :filename

      t.timestamps
    end
  end
end
