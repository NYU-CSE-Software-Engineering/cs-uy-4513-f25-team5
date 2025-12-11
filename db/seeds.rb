# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding test data for matching algorithm..."

# Clear existing data
User.destroy_all
Match.destroy_all
Listing.destroy_all

puts "Creating test users..."

# Test User 1 - Main user (you'll log in as this one)
user1 = User.create!(
  email: "test@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Alex Johnson",
  bio: "Graduate student looking for a roommate in Manhattan. I'm clean, quiet, and love to cook!",
  budget: 1500,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Room"
)

# Test User 2 - HIGH COMPATIBILITY (should match ~95-100%)
user2 = User.create!(
  email: "match1@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Sarah Chen",
  bio: "Early riser, loves fitness and cooking. Looking for a compatible roommate.",
  budget: 1550,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Roommate"
)

# Test User 3 - HIGH COMPATIBILITY (should match ~90-95%)
user3 = User.create!(
  email: "match2@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Mike Rodriguez",
  bio: "Software engineer, early bird, no pets. Very clean and organized.",
  budget: 1450,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Room"
)

# Test User 4 - MEDIUM COMPATIBILITY (should match ~70-80%)
user4 = User.create!(
  email: "match3@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Emma Wilson",
  bio: "Night owl, but flexible. Has a cat. Looking for pet-friendly roommate.",
  budget: 1600,
  preferred_location: "Manhattan",
  sleep_schedule: "Night Owl",
  pets: "Cat",
  housing_status: "Looking for Room"
)

# Test User 5 - MEDIUM COMPATIBILITY (should match ~60-70%)
user5 = User.create!(
  email: "match4@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "David Kim",
  bio: "Regular schedule, pet friendly. Budget is a bit higher.",
  budget: 2000,
  preferred_location: "Manhattan",
  sleep_schedule: "Regular Schedule",
  pets: "Pet Friendly",
  housing_status: "Looking for Roommate"
)

# Test User 6 - LOW COMPATIBILITY (should match ~50-60% - just above threshold)
user6 = User.create!(
  email: "match5@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Jordan Taylor",
  bio: "Different location but similar budget. Night owl.",
  budget: 1480,
  preferred_location: "Brooklyn",
  sleep_schedule: "Night Owl",
  pets: "None",
  housing_status: "Looking for Room"
)

# Test User 7 - VERY LOW COMPATIBILITY (should NOT match - below 50%)
user7 = User.create!(
  email: "nomatch@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Casey Brown",
  bio: "Very different preferences - should not match.",
  budget: 800,
  preferred_location: "Queens",
  sleep_schedule: "Night Owl",
  pets: "Dog",
  housing_status: "Have Room Available"
)

# Test User 8 - EDGE CASE: Missing some fields (should still match if enough data)
user8 = User.create!(
  email: "partial@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Riley Martinez",
  bio: "Has budget and location but missing sleep schedule.",
  budget: 1520,
  preferred_location: "Manhattan",
  sleep_schedule: nil,
  pets: "None",
  housing_status: "Looking for Room"
)

# Test User 9 - VARIATION TEST: Different format (should normalize and match)
user9 = User.create!(
  email: "variation@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Taylor Swift",
  bio: "Testing normalization - entered 'early bird' in lowercase.",
  budget: 1500,
  preferred_location: "manhattan",  # lowercase - should normalize
  sleep_schedule: "early bird",     # lowercase - should normalize
  pets: "none",                     # lowercase - should normalize
  housing_status: "looking for room" # lowercase - should normalize
)

# Test User 10 - PET FRIENDLY TEST (should match with "None")
user10 = User.create!(
  email: "petfriendly@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Sam Anderson",
  bio: "Pet friendly person - should match with people who have no pets.",
  budget: 1500,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "Pet Friendly",
  housing_status: "Looking for Roommate"
)

puts "✅ Created #{User.count} test users"

# Generate matches for user1 (the main test user)
puts "Generating matches for test user (test@example.com)..."

matches_created = MatchingService.generate_matches_for(user1)

puts "✅ Created #{matches_created} matches for test user"

# Display match summary
puts "\n📊 Match Summary:"
puts "=" * 50
Match.where(user_id: user1.id).includes(:matched_user).order(compatibility_score: :desc).each do |match|
  puts "#{match.matched_user.display_name.ljust(20)} | Score: #{match.compatibility_score.round(1).to_s.rjust(5)}% | #{match.matched_user.preferred_location} | #{match.matched_user.sleep_schedule} | #{match.matched_user.pets}"
end

puts "\n🎯 Test Scenarios Created:"
puts "  ✅ High compatibility matches (90-100%)"
puts "  ✅ Medium compatibility matches (60-80%)"
puts "  ✅ Low compatibility matches (50-60%)"
puts "  ✅ No match scenario (<50%)"
puts "  ✅ Partial data edge case"
puts "  ✅ Data normalization test"
puts "  ✅ Pet compatibility test"

puts "\n🔑 Login Credentials:"
puts "  Main Test User: test@example.com / password123"
puts "  All other users: [name]@example.com / password123"
puts "\n✨ Seeding complete!"
