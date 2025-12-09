# Matching Algorithm Data Sources

## Overview
The matching algorithm uses data from your **User Profile** to calculate compatibility scores between potential roommates.

---

## Currently Used Fields (Active in Matching Algorithm)

### 1. **Budget** (`budget`)
- **Location in Profile**: Edit Profile → Budget field
- **Weight**: 30% of compatibility score
- **How it works**: 
  - Compares your budget with potential matches
  - Calculates similarity: `1 - (budget_difference / average_budget)`
  - Closer budgets = higher match score
- **Example**: If you set $1500 and match has $1600, you get ~97% budget match

### 2. **Preferred Location** (`preferred_location`)
- **Location in Profile**: Edit Profile → Preferred location field
- **Weight**: 20% of compatibility score
- **How it works**: 
  - Exact match (case-insensitive) = +20 points
  - No match = 0 points
- **Example**: "Manhattan" matches with "manhattan" or "Manhattan"

### 3. **Sleep Schedule** (`sleep_schedule`)
- **Location in Profile**: Edit Profile → Sleep schedule field
- **Weight**: 20% of compatibility score
- **How it works**: 
  - Exact match (case-insensitive) = +20 points
  - No match = 0 points
- **Example**: "Early bird" matches with "early bird" or "Early Bird"

### 4. **Pets** (`pets`)
- **Location in Profile**: Edit Profile → Pets field
- **Weight**: 10% of compatibility score
- **How it works**: 
  - Exact match (case-insensitive) = +10 points
  - No match = 0 points
- **Example**: "Cat" matches with "cat" or "CAT"

---

## Available But NOT Currently Used

These fields exist in your profile but are **not yet** part of the matching algorithm:

### 5. **Housing Status** (`housing_status`)
- **Location in Profile**: Edit Profile → Housing status field
- **Status**: ⚠️ **NOT USED YET** (planned for Phase 3)
- **Planned Usage**: 
  - Match "Looking for roommate" with "Looking for room"
  - Match "Have room" with "Looking for room"
  - This will improve matching logic

### 6. **Bio** (`bio`)
- **Location in Profile**: Edit Profile → Bio textarea
- **Status**: ⚠️ **NOT USED YET**
- **Planned Usage**: 
  - Could be used for keyword matching
  - Displayed in match cards but not in algorithm

### 7. **Display Name** (`display_name`)
- **Location in Profile**: Edit Profile → Display name field
- **Status**: ⚠️ **NOT USED YET**
- **Usage**: Only for display purposes, not matching

### 8. **Contact Visibility** (`contact_visibility`)
- **Location in Profile**: Edit Profile → Contact visibility field
- **Status**: ⚠️ **NOT USED YET**
- **Usage**: Privacy setting, not matching

---

## How Matching Score is Calculated

```
Base Score: 50.0 points

+ Budget Match: up to 30 points (based on similarity)
+ Location Match: 20 points (if exact match)
+ Sleep Schedule Match: 20 points (if exact match)
+ Pets Match: 10 points (if exact match)

Maximum Score: 100 points
Minimum to Show: 50 points
```

### Example Calculation:
- User A: Budget=$1500, Location="Manhattan", Sleep="Early bird", Pets="Cat"
- User B: Budget=$1600, Location="Manhattan", Sleep="Early bird", Pets="Dog"

**Score Calculation:**
- Base: 50.0
- Budget: ~29.0 (very similar budgets)
- Location: +20.0 (match)
- Sleep: +20.0 (match)
- Pets: +0.0 (no match)
- **Total: 119.0 → Capped at 100.0**

---

## Where to Fill Profile Data

### Profile Edit Page
**URL**: `/profile/edit` or click "My Profile" → "Edit"

**Fields Used for Matching:**
1. ✅ **Budget** - Required for good matches
2. ✅ **Preferred Location** - Required for good matches
3. ✅ **Sleep Schedule** - Recommended
4. ✅ **Pets** - Optional but helps
5. ⚠️ **Housing Status** - Fill it now, will be used soon

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

1. **Housing Status Matching** - Match seekers with listers
2. **Age Range** - Add age preferences
3. **Lifestyle Tags** - Smoking, drinking, cleanliness
4. **Interests** - Hobbies and interests matching
5. **Match Reasons** - Show why two people matched

---

## Summary

**Currently Used (4 fields):**
- ✅ Budget (30%)
- ✅ Preferred Location (20%)
- ✅ Sleep Schedule (20%)
- ✅ Pets (10%)

**Available But Not Used (4 fields):**
- ⚠️ Housing Status (coming soon)
- ⚠️ Bio (display only)
- ⚠️ Display Name (display only)
- ⚠️ Contact Visibility (privacy only)

**To Get Best Matches:**
1. Fill in Budget, Preferred Location, and Sleep Schedule (required)
2. Add Pets preference (optional but helps)
3. Add Housing Status (will be used soon)
4. Update profile → Matches auto-regenerate!

