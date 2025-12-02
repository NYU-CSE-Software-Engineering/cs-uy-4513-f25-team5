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
Match.destroy_all
User.destroy_all
Listing.destroy_all

puts "Creating test users..."

# Main test user (you'll log in as this one)
main_user = User.create!(
  email: "test@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Test User",
  bio: "Looking for a compatible roommate in Brooklyn",
  budget: 1000,
  preferred_location: "Brooklyn, NY",
  sleep_schedule: "Early bird",
  pets: "No pets",
  housing_status: "Looking for roommate",
  contact_visibility: "Everyone"
)

# High compatibility match - similar budget, location, and preferences
alice = User.create!(
  email: "alice@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Alice Smith",
  bio: "Student looking for quiet roommate",
  budget: 950,
  preferred_location: "Brooklyn, NY",
  sleep_schedule: "Early bird",
  pets: "No pets",
  housing_status: "Looking for roommate",
  contact_visibility: "Everyone"
)

# Good compatibility match - similar budget, different location
bob = User.create!(
  email: "bob@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Bob Johnson",
  bio: "Professional working in tech, clean and organized",
  budget: 1100,
  preferred_location: "Queens, NY",
  sleep_schedule: "Early bird",
  pets: "No pets",
  housing_status: "Looking for roommate",
  contact_visibility: "Friends only"
)

# Medium compatibility match - different sleep schedule
charlie = User.create!(
  email: "charlie@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Charlie Brown",
  bio: "Night owl software developer",
  budget: 1050,
  preferred_location: "Brooklyn, NY",
  sleep_schedule: "Night owl",
  pets: "No pets",
  housing_status: "Looking for roommate",
  contact_visibility: "Everyone"
)

# Lower compatibility match - different budget and location
diana = User.create!(
  email: "diana@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Diana Prince",
  bio: "Artist looking for creative space",
  budget: 1500,
  preferred_location: "Manhattan, NY",
  sleep_schedule: "Flexible",
  pets: "Has a cat",
  housing_status: "Looking for roommate",
  contact_visibility: "Everyone"
)

# Another good match - very similar profile
emma = User.create!(
  email: "emma@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Emma Wilson",
  bio: "Graduate student, quiet and respectful",
  budget: 1000,
  preferred_location: "Brooklyn, NY",
  sleep_schedule: "Early bird",
  pets: "No pets",
  housing_status: "Looking for roommate",
  contact_visibility: "Everyone"
)

puts "Generating matches for test user..."
matches_created = MatchingService.generate_matches_for(main_user)
puts "Created #{matches_created} matches for test user"

# Also generate matches for other users so they can see matches too
puts "Generating matches for all users..."
total_matches = MatchingService.generate_all_matches
puts "Total matches created: #{total_matches}"

# Create some test listings
puts "Creating test listings..."
Listing.create!(
  title: "Cozy room near campus",
  description: "Furnished, utilities included",
  price: 600,
  city: "New York",
  status: Listing::STATUS_PENDING,
  owner_email: main_user.email,
  user: main_user
)

Listing.create!(
  title: "Downtown Studio",
  description: "Small but cozy studio apartment",
  price: 700,
  city: "Boston",
  status: Listing::STATUS_PENDING,
  owner_email: alice.email,
  user: alice
)

puts "Seeding complete!"
puts "\nTest accounts created:"
puts "  Main user: test@example.com / password123"
puts "  Alice: alice@example.com / password123"
puts "  Bob: bob@example.com / password123"
puts "  Charlie: charlie@example.com / password123"
puts "  Diana: diana@example.com / password123"
puts "  Emma: emma@example.com / password123"
puts "\nLog in as test@example.com to see matches!"
