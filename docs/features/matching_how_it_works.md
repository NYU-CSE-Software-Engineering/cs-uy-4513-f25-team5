# How Matching Works - User Guide

## Overview

The matching system automatically finds compatible roommates based on your profile preferences and calculates a compatibility score for each potential match.

## How You Get Matched (As a User)

### Step 1: Complete Your Profile
1. **Sign up** and create your account
2. **Fill out your profile** with:
   - Budget (how much you can spend on rent)
   - Preferred Location (where you want to live)
   - Sleep Schedule (Early bird, Night owl, Regular schedule)
   - Pets (Do you have pets? Are you okay with pets?)
   - Other preferences

### Step 2: Generate Matches
1. **Visit the Matches page** (`/matches`)
2. **Click "Find Matches" button**
3. The system will:
   - Search all other users in the system
   - Calculate compatibility scores
   - Create matches for users with scores >= 50%
   - Show you the results

### Step 3: View Your Matches
- You'll see a list of potential matches with:
  - Their name
  - Compatibility score (%)
  - Location
  - Budget
  - Click "View Details" to see more information

### Step 4: Like/Save Matches
- Click "Like" to save matches you're interested in
- You can review them later

## How Compatibility is Calculated

The system uses a weighted scoring system (0-100%):

| Factor | Weight | How it works |
|--------|--------|--------------|
| **Budget** | 30% | Calculates similarity between your budgets |
| **Location** | 20% | Matches if you both want the same location |
| **Sleep Schedule** | 20% | Matches if you have the same sleep schedule |
| **Pets** | 10% | Matches if you both have the same pet preference |
| **Base Score** | 20% | Everyone starts with 50% base score |

### Example Calculation:

**User A:**
- Budget: $1000
- Location: New York
- Sleep: Early bird
- Pets: No pets

**User B:**
- Budget: $950 (very similar!)
- Location: New York (match!)
- Sleep: Early bird (match!)
- Pets: No pets (match!)

**Result:** High compatibility score (~85-90%) because:
- Budgets are very similar (30 points)
- Same location (+20 points)
- Same sleep schedule (+20 points)
- Same pets (+10 points)
- Base score (+50 points)

## What Happens Behind the Scenes

### 1. MatchingService (Automatic Matching)

When you click "Find Matches", the `MatchingService`:

```ruby
MatchingService.generate_matches_for(current_user)
```

1. Finds all other users in the system (excludes yourself)
2. For each other user:
   - Calculates compatibility score using your profiles
   - Only creates a Match if score >= 50%
   - Prevents duplicate matches
3. Creates Match records in the database
4. Returns the number of matches created

### 2. Match Model

Each Match record stores:
- `user_id` - Your user ID
- `matched_user_id` - The other user's ID
- `compatibility_score` - Calculated score (0-100)
- Automatically calculates score when created

### 3. Displaying Matches

The MatchesController:
- Shows all matches where you are the `user_id`
- Orders them (you could sort by compatibility score)
- Shows "No matches found" if none exist

## Key Features

### ✅ Automatic Matching
- Click "Find Matches" to generate matches on demand
- System calculates compatibility automatically

### ✅ Duplicate Prevention
- Won't create the same match twice
- Checks if match already exists before creating

### ✅ Minimum Threshold
- Only creates matches with compatibility >= 50%
- Filters out incompatible matches

### ✅ Self-Matching Prevention
- Can't match with yourself
- Validates user_id != matched_user_id

## When Matches Are Generated

Currently, matches are generated:
- **Manually** - When you click "Find Matches" button
- **On-demand** - You control when to generate matches

### Future Enhancements (Not Yet Implemented):
- Automatic matching when you update your profile
- Automatic matching when you sign up
- Periodic background job to refresh matches
- Bidirectional matching (both users see each other)

## Code Components

### Files Created/Modified:

1. **`app/services/matching_service.rb`**
   - Core matching logic
   - `generate_matches_for(user)` - Generate for one user
   - `generate_all_matches` - Generate for all users
   - `regenerate_matches_for(user)` - Delete and recreate

2. **`app/controllers/matches_controller.rb`**
   - `generate` action - Handles "Find Matches" button click
   - Creates matches and shows success message

3. **`app/views/matches/index.html.erb`**
   - "Find Matches" button
   - Display list of matches

4. **`config/routes.rb`**
   - `POST /matches/generate` route

5. **`spec/services/matching_service_spec.rb`**
   - Tests for matching service logic

## Example User Flow

```
1. User signs up → Creates account
2. User fills profile → Budget: $1000, Location: NYC, Sleep: Early bird
3. User clicks "Find Matches" → MatchingService runs
4. System finds:
   - User B: $950, NYC, Early bird → Score: 85% ✅ Match created!
   - User C: $2000, LA, Night owl → Score: 45% ❌ No match (too low)
5. User sees matches → 1 match with User B
6. User clicks "View Details" → Sees full profile
7. User clicks "Like" → Saves match to favorites
```

## Technical Details

### Compatibility Score Formula:

```
Base Score = 50.0

+ Budget Similarity (0-30 points)
  = 1.0 - min(budget_difference / budget_average, 1.0) * 30

+ Location Match (0 or 20 points)
  = 20 if locations match exactly

+ Sleep Schedule Match (0 or 20 points)
  = 20 if schedules match exactly

+ Pets Match (0 or 10 points)
  = 10 if pet preferences match exactly

Final Score = min(Total Score, 100.0)
```

### Database Structure:

```sql
matches table:
- id
- user_id (the person looking for matches)
- matched_user_id (the potential match)
- compatibility_score (0-100)
- created_at
- updated_at
```

## Summary

**As a user, you:**
1. Fill out your profile
2. Click "Find Matches"
3. See compatible roommates with scores
4. View details and like matches you're interested in

**The system:**
1. Searches all users
2. Calculates compatibility
3. Creates matches automatically
4. Shows you the best matches first

You're now in control of when to find matches, and the system does all the heavy lifting!

