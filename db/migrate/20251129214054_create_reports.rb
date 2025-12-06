class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reported_user, null: false, foreign_key: { to_table: :users }
      t.string :report_type, null: false
      t.text :description
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
