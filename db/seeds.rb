# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# clear existing data
Report.destroy_all if defined?(Report)
User.destroy_all
Listing.destroy_all

# users
user1 = User.create!(email: "kevin@example.com", password: "password123", password_confirmation: "password123")
user2 = User.create!(email: "alex@example.com", password: "password123", password_confirmation: "password123")
# admin = User.create!(email: "admin@example.com", password: "adminpassword123", password_confirmation: "adminpassword123", role: "admin")

# listings
Listing.create!(
  title: "Cozy room near campus",
  description: "Furnished, utilities included",
  price: 600,
  city: "New York",
  status: Listing::STATUS_PENDING,
  owner_email: user1.email,
  user: user1
)

Listing.create!(
  title: "Downtown Studio",
  description: "Small but cozy studio apartment",
  price: 700,
  city: "Boston",
  status: Listing::STATUS_PENDING,
  owner_email: user2.email,
  user: user2
)
