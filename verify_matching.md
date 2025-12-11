# Quick Matching Algorithm Verification

## Option 1: Run Test Script (Recommended)

```bash
cd cs-uy-4513-f25-team5
rails runner test_matching_algorithm.rb
```

This will:
- Create test users
- Calculate compatibility scores
- Generate matches
- Verify all matching logic
- Show detailed test results

## Option 2: Manual Testing via Rails Console

```bash
cd cs-uy-4513-f25-team5
rails console
```

Then run:

```ruby
# Create test users
user1 = User.create!(
  email: "test@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Alex",
  budget: 1500,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None"
)

user2 = User.create!(
  email: "match@example.com",
  password: "password123",
  password_confirmation: "password123",
  display_name: "Sarah",
  budget: 1550,
  preferred_location: "Manhattan",
  sleep_schedule: "Early Bird",
  pets: "None"
)

# Test compatibility score calculation
score = Match.calculate_compatibility_score(user1, user2)
puts "Compatibility Score: #{score}%"
# Expected: ~95-100%

# Generate matches
matches = MatchingService.generate_matches_for(user1)
puts "Matches created: #{matches}"

# Check matches
Match.where(user_id: user1.id).each do |match|
  puts "#{match.matched_user.display_name}: #{match.compatibility_score.round(1)}%"
end
```

## Option 3: Test via UI

1. Run seeds: `rails db:seed`
2. Login as: `test@example.com` / `password123`
3. Go to: `/matches`
4. Verify matches appear with scores

## Expected Results

### High Compatibility (90-100%)
- Similar budget (±$100)
- Same location
- Same sleep schedule
- Compatible pets

### Medium Compatibility (60-80%)
- Similar budget
- Same location
- Different sleep schedule OR pets

### Low Compatibility (50-60%)
- Similar budget
- Different location
- Different sleep schedule

### No Match (<50%)
- Very different budget
- Different location
- Different sleep schedule
- Different pets

## Quick Verification Checklist

- [ ] Compatibility scores calculate correctly
- [ ] Matches are generated for compatible users
- [ ] No matches for incompatible users (<50%)
- [ ] Location variations work (NYC = New York)
- [ ] Pet compatibility works (Pet Friendly matches None)
- [ ] Data normalization works (lowercase → proper case)
- [ ] Minimum threshold enforced (50%)

