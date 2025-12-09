# Test Matches Guide

## Quick Start

Run the seed file to create test users and matches:

```bash
cd cs-uy-4513-f25-team5
rails db:seed
```

## Test User (Main Account)

**Login**: `test@example.com`  
**Password**: `password123`

This is the main test user. All matches are generated **for this user**.

---

## Test Scenarios Created

### ✅ High Compatibility Matches (90-100% score)

**User 2: Sarah Chen** (`match1@example.com`)
- Budget: $1550 (very similar to $1500)
- Location: Manhattan ✅
- Sleep: Early Bird ✅
- Pets: None ✅
- **Expected Score: ~95-100%**

**User 3: Mike Rodriguez** (`match2@example.com`)
- Budget: $1450 (very similar to $1500)
- Location: Manhattan ✅
- Sleep: Early Bird ✅
- Pets: None ✅
- **Expected Score: ~90-95%**

---

### ⚠️ Medium Compatibility Matches (60-80% score)

**User 4: Emma Wilson** (`match3@example.com`)
- Budget: $1600 (similar)
- Location: Manhattan ✅
- Sleep: Night Owl ❌ (different)
- Pets: Cat ❌ (different)
- **Expected Score: ~70-80%**

**User 5: David Kim** (`match5@example.com`)
- Budget: $2000 (different - larger gap)
- Location: Manhattan ✅
- Sleep: Regular Schedule ❌ (different)
- Pets: Pet Friendly ✅ (compatible with None)
- **Expected Score: ~60-70%**

---

### ⚠️ Low Compatibility Matches (50-60% score)

**User 6: Jordan Taylor** (`match5@example.com`)
- Budget: $1480 (similar)
- Location: Brooklyn ❌ (different)
- Sleep: Night Owl ❌ (different)
- Pets: None ✅
- **Expected Score: ~50-60%** (just above threshold)

---

### ❌ No Match (Below 50% threshold)

**User 7: Casey Brown** (`nomatch@example.com`)
- Budget: $800 (very different)
- Location: Queens ❌ (different)
- Sleep: Night Owl ❌ (different)
- Pets: Dog ❌ (different)
- **Expected Score: <50%** (should NOT appear in matches)

---

### 🔍 Edge Cases

**User 8: Riley Martinez** (`partial@example.com`)
- Budget: $1520 ✅
- Location: Manhattan ✅
- Sleep: **Missing** ❌
- Pets: None ✅
- **Expected Score: ~70-80%** (location + budget match)

**User 9: Taylor Swift** (`variation@example.com`)
- Tests data normalization
- Entered lowercase: "manhattan", "early bird", "none"
- Should normalize to: "Manhattan", "Early Bird", "None"
- **Expected Score: ~95-100%** (perfect match after normalization)

**User 10: Sam Anderson** (`petfriendly@example.com`)
- Budget: $1500 ✅
- Location: Manhattan ✅
- Sleep: Early Bird ✅
- Pets: **Pet Friendly** ✅ (should match with "None")
- **Expected Score: ~95-100%**

---

## How to Test

### 1. Run Seeds
```bash
rails db:seed
```

### 2. Login as Test User
- Go to `/auth/login`
- Email: `test@example.com`
- Password: `password123`

### 3. View Matches
- Go to `/matches` or click "Find Roommates"
- You should see matches sorted by compatibility score

### 4. Check Match Details
- Click on any match to see details
- Verify compatibility scores match expectations
- Check that "nomatch@example.com" does NOT appear

### 5. Test Normalization
- Login as `variation@example.com` / `password123`
- Check their profile - values should be normalized
- Generate matches - should match with test user

---

## Expected Match Count

After seeding, the test user should have **~8 matches**:
- ✅ 2 high compatibility (90-100%)
- ✅ 2 medium compatibility (60-80%)
- ✅ 1 low compatibility (50-60%)
- ✅ 1 edge case (partial data)
- ✅ 1 normalization test
- ✅ 1 pet friendly test
- ❌ 1 no match (should NOT appear)

---

## Testing Different Scenarios

### Test Budget Matching
1. Login as test user
2. Update budget to $2000
3. Save profile
4. Check matches - scores should change
5. User 5 (David Kim) should have higher score now

### Test Location Matching
1. Update preferred_location to "Brooklyn"
2. Save profile
3. User 6 (Jordan Taylor) should have higher score
4. Manhattan matches should have lower scores

### Test Sleep Schedule Matching
1. Update sleep_schedule to "Night Owl"
2. Save profile
3. User 4 (Emma Wilson) should have higher score
4. Early Bird matches should have lower scores

### Test Pet Compatibility
1. Update pets to "Cat"
2. Save profile
3. User 4 (Emma Wilson) should have higher score
4. User 10 (Sam Anderson - Pet Friendly) should still match

---

## All Test User Credentials

| Email | Password | Name | Purpose |
|-------|----------|------|---------|
| test@example.com | password123 | Alex Johnson | Main test user |
| match1@example.com | password123 | Sarah Chen | High compatibility |
| match2@example.com | password123 | Mike Rodriguez | High compatibility |
| match3@example.com | password123 | Emma Wilson | Medium compatibility |
| match4@example.com | password123 | David Kim | Medium compatibility |
| match5@example.com | password123 | Jordan Taylor | Low compatibility |
| nomatch@example.com | password123 | Casey Brown | No match |
| partial@example.com | password123 | Riley Martinez | Edge case |
| variation@example.com | password123 | Taylor Swift | Normalization test |
| petfriendly@example.com | password123 | Sam Anderson | Pet compatibility |

---

## Troubleshooting

### No matches showing?
1. Check that seeds ran successfully
2. Verify test user has budget, location, sleep_schedule filled
3. Check console for errors: `rails console` → `Match.count`

### Wrong scores?
1. Check normalization is working: `User.find_by(email: 'variation@example.com').sleep_schedule`
2. Verify matching algorithm: `Match.calculate_compatibility_score(user1, user2)`

### Missing users?
1. Re-run seeds: `rails db:seed`
2. Check database: `rails console` → `User.count` (should be 10)

---

## Next Steps

After testing:
1. Verify all matches appear correctly
2. Check compatibility scores are accurate
3. Test match details page
4. Test profile updates regenerate matches
5. Test edge cases (missing data, variations)

