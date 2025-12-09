# Roommate Matching Refocus Plan

## Current Problem
The app currently looks like Zillow/apartments.com - focused on browsing listings rather than finding compatible roommates using the matching algorithm. The matching feature exists but is secondary.

## Goal
Transform RoomMate into a **roommate-first matching platform** where:
- **Primary Flow**: Users find compatible roommates through the matching algorithm
- **Secondary Flow**: Listings are for people who already have a place and want to find a roommate
- **Matching is automatic and prominent** - not hidden behind a button

---

## Phase 1: Make Matching the Primary Experience (HIGH PRIORITY)

### 1.1 Dashboard Refocus
**Current State**: Dashboard shows "My Listings", "Search Listings", "Create Listing" as primary actions
**Target State**: Dashboard should prioritize matching

**Changes Needed**:
- [ ] **Reorder Quick Actions**: Put "Find Roommates" (matches) as the FIRST and most prominent card
- [ ] **Add Match Stats**: Show "X potential matches", "Y conversations", "Z active matches" on dashboard
- [ ] **Auto-generate matches on login**: When user logs in, automatically run matching algorithm (if profile is complete)
- [ ] **Match Preview**: Show top 3 matches on dashboard with compatibility scores
- [ ] **Move Listings to Secondary**: Listings should be in a "For Room Listers" section

**Files to Modify**:
- `app/views/dashboards/show.html.erb`
- `app/controllers/dashboards_controller.rb` (add match stats)
- `app/controllers/sessions_controller.rb` (auto-generate matches after login)

### 1.2 Homepage Refocus
**Current State**: Homepage says "Explore listings, create profiles, and discover verified spaces"
**Target State**: Emphasize roommate matching

**Changes Needed**:
- [ ] **Update Hero Text**: "Find your perfect roommate using our smart matching algorithm"
- [ ] **Change CTA**: Primary button should be "Find My Matches" not "View Listings"
- [ ] **Update Stats**: Show "X Matches Made", "Y Active Users", "Z% Match Success Rate"
- [ ] **Add Matching Explanation**: Brief section explaining how the algorithm works

**Files to Modify**:
- `app/views/pages/home.html.erb`

### 1.3 Navigation Refocus
**Current State**: Navbar has "My Listings", "Search Listings" prominently
**Target State**: "Find Roommates" should be most prominent

**Changes Needed**:
- [ ] **Reorder Navbar**: "Find Roommates" → "My Matches" → "Messages" → "Profile" → (Listings in dropdown)
- [ ] **Rename "Matches" to "Find Roommates"** for clarity
- [ ] **Add Match Badge**: Show count of new matches (if any)

**Files to Modify**:
- `app/views/shared/_navbar.html.erb`

---

## Phase 2: Improve Matching Flow & UX (HIGH PRIORITY)

### 2.1 Automatic Match Generation
**Current State**: User must click "Find Matches" button manually
**Target State**: Matches generate automatically when profile is complete

**Changes Needed**:
- [ ] **Auto-generate on profile completion**: When user completes/updates profile, automatically regenerate matches
- [ ] **Background job**: Use ActiveJob to generate matches asynchronously
- [ ] **Match freshness**: Show "Last updated: X hours ago" and allow manual refresh
- [ ] **Smart notifications**: Notify user when new matches are found

**Files to Modify**:
- `app/controllers/profiles_controller.rb` (after_update callback)
- `app/jobs/match_generation_job.rb` (new file)
- `app/models/user.rb` (add callback)
- `app/views/matches/index.html.erb` (add refresh indicator)

### 2.2 Enhanced Match Display
**Current State**: Basic match cards with name, score, location, budget
**Target State**: Rich match cards with more info and actions

**Changes Needed**:
- [ ] **Match Cards Should Show**:
  - Compatibility breakdown (why they match: "Budget: 95% match", "Location: Match", etc.)
  - Profile photo/avatar
  - Bio preview
  - Lifestyle tags (Early Bird, Pet Friendly, etc.)
  - "Message" button (creates conversation)
  - "Like" button (save for later)
  - "Pass" button (hide this match)
- [ ] **Sort by Compatibility**: Show highest matches first
- [ ] **Filter Matches**: By location, budget range, lifestyle preferences
- [ ] **Match Details Page**: Enhanced view with full profile, compatibility breakdown, shared preferences

**Files to Modify**:
- `app/views/matches/index.html.erb`
- `app/views/matches/show.html.erb`
- `app/controllers/matches_controller.rb` (add filters, sorting)
- `app/models/match.rb` (add methods for compatibility breakdown)

### 2.3 Match-to-Conversation Flow
**Current State**: Matches and conversations are separate
**Target State**: Seamless flow from match to conversation

**Changes Needed**:
- [ ] **"Message" button on match card**: Creates conversation if doesn't exist
- [ ] **Show conversation status**: "Already chatting" badge if conversation exists
- [ ] **Link from match to conversation**: Direct link to existing conversation
- [ ] **Match context in conversation**: Show compatibility score in conversation header

**Files to Modify**:
- `app/controllers/matches_controller.rb` (add message action)
- `app/controllers/conversations_controller.rb` (create from match)
- `app/views/matches/index.html.erb` (add message button)
- `app/views/conversations/show.html.erb` (show match info)

---

## Phase 3: Enhance Matching Algorithm Integration (MEDIUM PRIORITY)

### 3.1 Profile Completion Requirements
**Current State**: Users can have incomplete profiles
**Target State**: Encourage complete profiles for better matching

**Changes Needed**:
- [ ] **Profile Completeness Score**: Show "Profile 60% complete" with missing fields
- [ ] **Required Fields for Matching**: Budget, preferred_location, sleep_schedule minimum
- [ ] **Onboarding Flow**: Guide new users to complete profile before matching
- [ ] **Match Quality Indicator**: "Complete your profile to see more matches"

**Files to Modify**:
- `app/models/user.rb` (add profile_completeness method)
- `app/views/profiles/show.html.erb` (show completeness)
- `app/views/matches/index.html.erb` (show if profile incomplete)

### 3.2 Enhanced Matching Criteria
**Current State**: Algorithm uses budget, location, sleep schedule, pets
**Target State**: More sophisticated matching

**Changes Needed**:
- [ ] **Housing Status Matching**: Match "Looking for roommate" with "Looking for room"
- [ ] **Age Range Preference**: Add age/age_range to user model and matching
- [ ] **Lifestyle Tags**: Smoking, drinking, cleanliness, noise level
- [ ] **Interests/Hobbies**: For better compatibility
- [ ] **Match Reasons**: Show why two people matched (e.g., "You both prefer early mornings and have similar budgets")

**Files to Modify**:
- `app/models/match.rb` (enhance calculate_compatibility_score)
- `app/models/user.rb` (add new fields)
- `db/migrate/xxxx_add_matching_fields_to_users.rb` (new migration)
- `app/views/matches/show.html.erb` (show match reasons)

### 3.3 Match Quality & Feedback
**Current State**: No feedback loop on match quality
**Target State**: Learn from user interactions

**Changes Needed**:
- [ ] **Match Actions Tracking**: Track likes, passes, messages, conversations
- [ ] **Match Success Metrics**: Track if matches lead to conversations/meetings
- [ ] **User Feedback**: "Was this a good match?" after conversation
- [ ] **Algorithm Tuning**: Use feedback to improve matching weights

**Files to Modify**:
- `app/models/match.rb` (add status: pending, liked, passed, messaged)
- `app/controllers/matches_controller.rb` (track actions)
- `db/migrate/xxxx_add_status_to_matches.rb` (new migration)

---

## Phase 4: Redesign Listings as Secondary Feature (MEDIUM PRIORITY)

### 4.1 Listings for Room Listers Only
**Current State**: Anyone can create listings
**Target State**: Listings are for people who have a place and want a roommate

**Changes Needed**:
- [ ] **Housing Status Check**: Only allow listings if housing_status = "Have room" or "Looking for roommate"
- [ ] **Listing Context**: "I have a room available" vs "Looking for a place"
- [ ] **Link Listings to Matches**: Show "Potential roommates for this listing" based on matching
- [ ] **Listing-Match Integration**: When viewing a listing, show matched users who might be interested

**Files to Modify**:
- `app/controllers/listings_controller.rb` (add housing_status check)
- `app/views/listings/new.html.erb` (add context)
- `app/views/listings/show.html.erb` (show potential matches)

### 4.2 Move Listings to Secondary Position
**Current State**: Listings are primary navigation items
**Target State**: Listings are in a "For Room Listers" section

**Changes Needed**:
- [ ] **Create "For Room Listers" Section**: Collapsible section on dashboard
- [ ] **Move Listings to Dropdown**: "Listings" → "My Listings", "Create Listing", "Search Listings"
- [ ] **De-emphasize in Navbar**: Move listings to end or dropdown menu

**Files to Modify**:
- `app/views/dashboards/show.html.erb`
- `app/views/shared/_navbar.html.erb`

---

## Phase 5: User Onboarding & Education (LOW PRIORITY)

### 5.1 New User Flow
**Changes Needed**:
- [ ] **Welcome Tour**: Explain matching algorithm on first login
- [ ] **Profile Setup Wizard**: Step-by-step guide to complete profile
- [ ] **Match Explanation**: "How matching works" page/tooltip
- [ ] **First Match Celebration**: Show excitement when first matches are found

**Files to Create**:
- `app/views/onboarding/welcome.html.erb`
- `app/views/onboarding/profile_setup.html.erb`
- `app/controllers/onboarding_controller.rb`

### 5.2 Help & Documentation
**Changes Needed**:
- [ ] **"How It Works" Page**: Explain matching algorithm
- [ ] **FAQ**: Common questions about matching
- [ ] **Tips for Better Matches**: Guide users on completing profiles

**Files to Create**:
- `app/views/pages/how_it_works.html.erb`
- `app/views/pages/faq.html.erb`

---

## Implementation Priority

### Week 1 (Critical Path)
1. ✅ Dashboard refocus (make matches primary)
2. ✅ Homepage refocus (emphasize matching)
3. ✅ Navigation refocus (matches first)
4. Auto-generate matches on profile update
5. Enhanced match cards with more info

### Week 2 (Core Features)
1. Match-to-conversation flow
2. Profile completeness requirements
3. Housing status matching
4. Match filtering and sorting

### Week 3 (Polish)
1. Listings as secondary feature
2. Match quality tracking
3. User onboarding flow
4. Help documentation

---

## Success Metrics

**Before**: 
- Users primarily browse listings
- Matching is hidden/optional
- Low match engagement

**After**:
- Users primarily use matching feature
- High match-to-conversation conversion
- Users complete profiles for better matches
- Listings are secondary (for room listers)

---

## Technical Considerations

1. **Performance**: Auto-generating matches should be async (ActiveJob)
2. **Database**: May need indexes on matching fields (budget, location, etc.)
3. **Caching**: Cache match results for X hours to avoid regeneration
4. **Notifications**: Real-time notifications for new matches (ActionCable)
5. **Testing**: Update Cucumber features to reflect new matching-first flow

---

## Files Summary

### Files to Modify (Existing)
- `app/views/dashboards/show.html.erb`
- `app/views/pages/home.html.erb`
- `app/views/shared/_navbar.html.erb`
- `app/views/matches/index.html.erb`
- `app/views/matches/show.html.erb`
- `app/controllers/matches_controller.rb`
- `app/controllers/dashboards_controller.rb`
- `app/controllers/profiles_controller.rb`
- `app/controllers/sessions_controller.rb`
- `app/models/match.rb`
- `app/models/user.rb`

### Files to Create (New)
- `app/jobs/match_generation_job.rb`
- `app/views/onboarding/welcome.html.erb`
- `app/views/pages/how_it_works.html.erb`
- `db/migrate/xxxx_add_status_to_matches.rb`
- `db/migrate/xxxx_add_matching_fields_to_users.rb`

---

## Next Steps

1. Review and approve this plan
2. Start with Phase 1 (Dashboard/Homepage/Navigation refocus)
3. Test matching flow with real users
4. Iterate based on feedback
5. Continue with subsequent phases

