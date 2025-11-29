class MakeListingsUserIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :listings, :user_id, true
  end
end
