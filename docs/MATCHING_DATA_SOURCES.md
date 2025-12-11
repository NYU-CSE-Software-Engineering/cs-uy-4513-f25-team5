# Matching Algorithm Data Sources

## Overview
The matching algorithm uses data from your **User Profile** to calculate compatibility scores between potential roommates.

---

## Currently Used Fields (Active in Matching Algorithm)

### 1. **Budget** (`budget`)
- **Location in Profile**: Edit Profile → Budget field
- **Weight**: 25% of compatibility score
- **How it works**: 
  - Compares your budget with potential matches
  - Calculates similarity: `1 - (budget_difference / average_budget)`
  - Closer budgets = higher match score
- **Example**: If you set $1500 and match has $1600, you get ~97% budget match

### 2. **Preferred Location** (`preferred_location`)
- **Location in Profile**: Edit Profile → Preferred location field
- **Weight**: 15% of compatibility score
- **How it works**: 
  - Exact match (case-insensitive) = +15 points
  - Smart matching for NYC variations (Manhattan, NYC, Brooklyn, etc.)
  - No match = 0 points
- **Example**: "Manhattan" matches with "manhattan", "NYC", or "New York"

### 3. **Sleep Schedule** (`sleep_schedule`)
- **Location in Profile**: Edit Profile → Sleep schedule field
- **Weight**: 15% of compatibility score
- **How it works**: 
  - Exact match (case-insensitive) = +15 points
  - No match = 0 points
- **Example**: "Early bird" matches with "early bird" or "Early Bird"

### 4. **Pets** (`pets`)
- **Location in Profile**: Edit Profile → Pets field
- **Weight**: 10% of compatibility score
- **How it works**: 
  - Exact match = +10 points
  - "Pet Friendly" matches with any pet type
  - "None" only matches with "None" or "Pet Friendly"
- **Example**: "Cat" matches with "cat", or "Pet Friendly" matches with "Dog"

### 5. **Housing Status** (`housing_status`)
- **Location in Profile**: Edit Profile → Housing status field
- **Weight**: Up to 10% of compatibility score
- **How it works**: 
  - "Looking for Room" + "Have Room Available" = +10 points (perfect match!)
  - "Looking for Room" + "Looking for Roommate" = +10 points (perfect match!)
  - "Flexible" matches with anything = +10 points
  - Same status (both looking for room) = +5 points (could team up)
  - No compatibility = 0 points
- **Example**: If you're "Looking for Room" and they "Have Room Available", perfect match!

### 6. **Common Liked Listings** (`liked_listings`)
- **Location in Profile**: Explore page → Like listings
- **Weight**: Up to 15% of compatibility score
- **How it works**: 
  - Calculates overlap: `common_listings / total_unique_listings`
  - More common listings = higher score
  - Shows you match on housing preferences!
- **Example**: If you both liked 3 out of 5 unique listings = +9 points (60% overlap)

---

## Available But NOT Currently Used

These fields exist in your profile but are **not yet** part of the matching algorithm:

### 7. **Bio** (`bio`)
- **Location in Profile**: Edit Profile → Bio textarea
- **Status**: ⚠️ **NOT USED YET**
- **Planned Usage**: 
  - Could be used for keyword matching
  - Displayed in match cards but not in algorithm

### 8. **Display Name** (`display_name`)
- **Location in Profile**: Edit Profile → Display name field
- **Status**: ⚠️ **NOT USED YET**
- **Usage**: Only for display purposes, not matching

### 9. **Contact Visibility** (`contact_visibility`)
- **Location in Profile**: Edit Profile → Contact visibility field
- **Status**: ⚠️ **NOT USED YET**
- **Usage**: Privacy setting, not matching

---

## How Matching Score is Calculated

```
Base Score: 40.0 points

+ Budget Match: up to 25 points (based on similarity)
+ Location Match: 15 points (if match)
+ Sleep Schedule Match: 15 points (if exact match)
+ Pets Match: 10 points (if compatible)
+ Housing Status Match: up to 10 points (based on compatibility)
+ Common Liked Listings: up to 15 points (based on overlap)

Maximum Score: 130 points → Capped at 100 points
Minimum to Show: 50 points (configurable in MatchingService)
```

### Example Calculation:
- User A: Budget=$1500, Location="Manhattan", Sleep="Early bird", Pets="Cat", Status="Looking for Room"
- User B: Budget=$1600, Location="Manhattan", Sleep="Early bird", Pets="Pet Friendly", Status="Have Room Available"
- Both liked 3 common listings out of 5 total unique listings

**Score Calculation:**
- Base: 40.0
- Budget: ~24.0 (very similar budgets, ~96% match)
- Location: +15.0 (match)
- Sleep: +15.0 (match)
- Pets: +10.0 (Pet Friendly matches with Cat)
- Housing Status: +10.0 (perfect complementary match!)
- Common Listings: +9.0 (60% overlap: 3/5 = 0.6 * 15)
- **Total: 123.0 → Capped at 100.0**

---

## Where to Fill Profile Data

### Profile Edit Page
**URL**: `/profile/edit` or click "My Profile" → "Edit"

**Fields Used for Matching:**
1. ✅ **Budget** - Required for good matches
2. ✅ **Preferred Location** - Required for good matches
3. ✅ **Sleep Schedule** - Recommended
4. ✅ **Pets** - Optional but helps
5. ✅ **Housing Status** - Very important! Helps match seekers with listers
6. ✅ **Liked Listings** - Like listings in Explore page to show preference overlap

### Auto-Match Generation
When you update any of these fields, matches are **automatically regenerated**:
- Budget
- Preferred Location
- Sleep Schedule
- Pets
- Housing Status

---

## Profile Completeness Check

The dashboard shows if your profile is complete enough for matching:

**Required for Matching:**
- ✅ Budget
- ✅ Preferred Location
- ✅ Sleep Schedule

**Optional but Recommended:**
- Pets
- Housing Status
- Bio

---

## Code Locations

### Matching Algorithm
- **File**: `app/models/match.rb`
- **Method**: `Match.calculate_compatibility_score(user1, user2)`
- **Lines**: 14-50

### Profile Fields
- **Model**: `app/models/user.rb`
- **Schema**: `db/schema.rb` (lines 80-95)
- **Edit Form**: `app/views/profiles/edit.html.erb`

### Auto-Regeneration
- **File**: `app/controllers/profiles_controller.rb`
- **Method**: `update` (lines 11-23)
- **Trigger**: When profile fields change

---

## Future Enhancements (Planned)

1. **Age Range** - Add age preferences
2. **Lifestyle Tags** - Smoking, drinking, cleanliness preferences
3. **Interests** - Hobbies and interests matching
4. **Match Reasons** - Show detailed breakdown of why two people matched
5. **Move-in Date** - Match based on timeline preferences

---

## Summary

**Currently Used (6 fields):**
- ✅ Budget (25%)
- ✅ Preferred Location (15%)
- ✅ Sleep Schedule (15%)
- ✅ Pets (10%)
- ✅ Housing Status (up to 10%)
- ✅ Common Liked Listings (up to 15%)

**Available But Not Used (3 fields):**
- ⚠️ Bio (display only)
- ⚠️ Display Name (display only)
- ⚠️ Contact Visibility (privacy only)

**To Get Best Matches:**
1. Fill in Budget, Preferred Location, and Sleep Schedule (required)
2. Add Pets preference (optional but helps)
3. Add Housing Status - VERY IMPORTANT for matching seekers with listers!
4. Like listings in the Explore page to show your preferences
5. Update profile → Matches auto-regenerate!

