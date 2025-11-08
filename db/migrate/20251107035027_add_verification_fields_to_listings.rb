class AddVerificationFieldsToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :owner_email, :string
    add_column :listings, :status, :string
    add_column :listings, :verification_requested, :boolean, default: false
    add_column :listings, :verified, :boolean, default: false
  end
end
