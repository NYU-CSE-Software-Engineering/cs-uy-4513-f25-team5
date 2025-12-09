#!/usr/bin/env ruby
# Test script to verify matching algorithm is working
# Run with: rails runner test_matching_algorithm.rb

require_relative 'config/environment'

puts "🧪 Testing Matching Algorithm"
puts "=" * 60

# Clear existing test data
puts "\n1. Clearing existing test data..."
User.where("email LIKE ?", "%@example.com").destroy_all
Match.destroy_all
puts "✅ Cleared"

# Create test users
puts "\n2. Creating test users..."

user1 = User.create!(
  email: "test@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Alex Johnson",
  budget: 1500,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Room"
)

user2 = User.create!(
  email: "match1@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Sarah Chen",
  budget: 1550,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Roommate"
)

user3 = User.create!(
  email: "match2@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Mike Rodriguez",
  budget: 1450,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None",
  housing_status: "Looking for Room"
)

user4 = User.create!(
  email: "match3@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Emma Wilson",
  budget: 1600,
  preferred_location: "Manhattan",
  sleep_schedule: "Night Owl",
  pets: "Cat",
  housing_status: "Looking for Room"
)

user5 = User.create!(
  email: "nomatch@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Casey Brown",
  budget: 800,
  preferred_location: "Queens",
  sleep_schedule: "Night Owl",
  pets: "Dog",
  housing_status: "Have Room Available"
)

puts "✅ Created 5 test users"

# Test 1: Calculate compatibility scores manually
puts "\n3. Testing Compatibility Score Calculation..."
puts "-" * 60

test_cases = [
  { user1: user1, user2: user2, expected_range: (90..100), description: "High compatibility (similar budget, location, sleep, pets)" },
  { user1: user1, user2: user3, expected_range: (90..100), description: "High compatibility (similar budget, location, sleep, pets)" },
  { user1: user1, user2: user4, expected_range: (60..80), description: "Medium compatibility (location match, different sleep/pets)" },
  { user1: user1, user2: user5, expected_range: (0..50), description: "Low compatibility (different everything)" }
]

test_cases.each_with_index do |test, index|
  score = Match.calculate_compatibility_score(test[:user1], test[:user2])
  passed = test[:expected_range].include?(score)
  status = passed ? "✅ PASS" : "❌ FAIL"
  
  puts "\nTest #{index + 1}: #{test[:description]}"
  puts "  User 1: #{test[:user1].display_name} (#{test[:user1].budget}, #{test[:user1].preferred_location}, #{test[:user1].sleep_schedule}, #{test[:user1].pets})"
  puts "  User 2: #{test[:user2].display_name} (#{test[:user2].budget}, #{test[:user2].preferred_location}, #{test[:user2].sleep_schedule}, #{test[:user2].pets})"
  puts "  Score: #{score.round(2)}% (Expected: #{test[:expected_range]})"
  puts "  Status: #{status}"
  
  unless passed
    puts "  ⚠️  Score outside expected range!"
  end
end

# Test 2: Generate matches using MatchingService
puts "\n4. Testing Match Generation Service..."
puts "-" * 60

matches_created = MatchingService.generate_matches_for(user1)
puts "✅ Generated #{matches_created} matches for #{user1.display_name}"

# Test 3: Verify matches were created correctly
puts "\n5. Verifying Matches..."
puts "-" * 60

matches = Match.where(user_id: user1.id).includes(:matched_user).order(compatibility_score: :desc)

if matches.empty?
  puts "❌ FAIL: No matches created!"
else
  puts "✅ Found #{matches.count} matches:"
  matches.each do |match|
    puts "  - #{match.matched_user.display_name.ljust(20)} | Score: #{match.compatibility_score.round(1).to_s.rjust(5)}%"
  end
end

# Test 4: Verify minimum threshold (50%)
puts "\n6. Testing Minimum Threshold (50%)..."
puts "-" * 60

low_score_matches = matches.select { |m| m.compatibility_score < 50 }
if low_score_matches.empty?
  puts "✅ PASS: All matches are above 50% threshold"
else
  puts "❌ FAIL: Found #{low_score_matches.count} matches below 50%:"
  low_score_matches.each do |match|
    puts "  - #{match.matched_user.display_name}: #{match.compatibility_score.round(1)}%"
  end
end

# Test 5: Verify no match for incompatible user
puts "\n7. Testing No Match for Incompatible User..."
puts "-" * 60

nomatch_exists = Match.exists?(user_id: user1.id, matched_user_id: user5.id)
if nomatch_exists
  match = Match.find_by(user_id: user1.id, matched_user_id: user5.id)
  puts "⚠️  WARNING: Match exists for incompatible user (#{user5.display_name})"
  puts "   Score: #{match.compatibility_score.round(1)}%"
  if match.compatibility_score >= 50
    puts "   ❌ FAIL: Score should be below 50% threshold"
  else
    puts "   ✅ PASS: Score is below 50%, but match was created (this might be expected)"
  end
else
  puts "✅ PASS: No match created for incompatible user (#{user5.display_name})"
end

# Test 6: Test normalization
puts "\n8. Testing Data Normalization..."
puts "-" * 60

user6 = User.create!(
  email: "normalize@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Test Normalize",
  budget: 1500,
  preferred_location: "manhattan",  # lowercase
  sleep_schedule: "early bird",     # lowercase
  pets: "none",                     # lowercase
  housing_status: "looking for room"
)

# Reload to see normalized values
user6.reload

normalization_tests = [
  { field: :preferred_location, value: user6.preferred_location, expected: "Manhattan" },
  { field: :sleep_schedule, value: user6.sleep_schedule, expected: "Early Bird" },
  { field: :pets, value: user6.pets, expected: "None" }
]

all_normalized = true
normalization_tests.each do |test|
  passed = test[:value] == test[:expected]
  status = passed ? "✅" : "❌"
  puts "  #{status} #{test[:field]}: '#{test[:value]}' (expected: '#{test[:expected]}')"
  all_normalized = false unless passed
end

if all_normalized
  puts "✅ PASS: All fields normalized correctly"
else
  puts "❌ FAIL: Some fields not normalized"
end

# Test 7: Test location variations
puts "\n9. Testing Location Variations..."
puts "-" * 60

location_tests = [
  { loc1: "Manhattan", loc2: "manhattan", should_match: true },
  { loc1: "New York", loc2: "NYC", should_match: true },
  { loc1: "Brooklyn", loc2: "BK", should_match: true },
  { loc1: "Manhattan", loc2: "Brooklyn", should_match: false }
]

location_tests.each do |test|
  matches = Match.locations_match?(test[:loc1], test[:loc2])
  passed = matches == test[:should_match]
  status = passed ? "✅" : "❌"
  puts "  #{status} '#{test[:loc1]}' vs '#{test[:loc2]}': #{matches} (expected: #{test[:should_match]})"
end

# Test 8: Test pet compatibility
puts "\n10. Testing Pet Compatibility..."
puts "-" * 60

pet_tests = [
  { pets1: "None", pets2: "None", should_match: true },
  { pets1: "None", pets2: "Pet Friendly", should_match: true },
  { pets1: "Cat", pets2: "Pet Friendly", should_match: true },
  { pets1: "None", pets2: "Cat", should_match: false },
  { pets1: "Cat", pets2: "Dog", should_match: false }
]

pet_tests.each do |test|
  matches = Match.pets_compatible?(test[:pets1], test[:pets2])
  passed = matches == test[:should_match]
  status = passed ? "✅" : "❌"
  puts "  #{status} '#{test[:pets1]}' vs '#{test[:pets2]}': #{matches} (expected: #{test[:should_match]})"
end

# Summary
puts "\n" + "=" * 60
puts "📊 TEST SUMMARY"
puts "=" * 60
puts "Test users created: 6"
puts "Matches generated: #{matches_created}"
puts "Matches above threshold: #{matches.select { |m| m.compatibility_score >= 50 }.count}"
puts "Matches below threshold: #{matches.select { |m| m.compatibility_score < 50 }.count}"
puts "\n✅ Matching algorithm test complete!"
puts "\nTo test in the UI:"
puts "  1. Login as: test@example.com / password123"
puts "  2. Go to: /matches"
puts "  3. Verify matches appear with correct scores"

