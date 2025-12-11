# Liked Listing Matches Feature

## Overview

This feature implements a two-part system for listing discovery:

1. **Match-Based Listing Discovery**: Users can see listings that their matched roommates have liked
2. **Explore Page**: Independent browsing of random listings not tied to matches

## Architecture

### Core Concept

**Matching is the foundation** - Users get matched based on multiple compatibility factors, and common liked listings is ONE of several variables in the matching score, but NOT the sole criteria.

### Flow

```
Step 1: Users create profiles/preferences
   ↓
Step 2: Matching algorithm runs (scores based on multiple factors including common liked listings)
   ↓
Step 3: Users get matched
   ↓
Step 4: Matched users can see "What Your Matches Liked"
   +
Step 5: Users can also browse "Explore" page independently
```

## Database Schema

### New Table: `liked_listings`

```ruby
create_table :liked_listings do |t|
  t.references :user, null: false, foreign_key: true
  t.references :listing, null: false, foreign_key: true
  t.timestamps
end

add_index :liked_listings, [:user_id, :listing_id], unique: true
```

## Models

### LikedListing Model

```ruby
class LikedListing < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  validates :user_id, uniqueness: { scope: :listing_id }
end
```

### Updated User Model

New associations and methods:
- `has_many :liked_listings`
- `has_many :liked_listings_records, through: :liked_listings, source: :listing`
- `liked?(listing)` - Check if user has liked a specific listing
- `matched_users` - Get all matched users
- `matches_liked_listings` - Get listings liked by matched users

### Updated Listing Model

New associations:
- `has_many :liked_listings`
- `has_many :liked_by_users, through: :liked_listings, source: :user`

### Updated Match Model

The compatibility scoring algorithm now includes common liked listings as a factor:

**New Weight Distribution:**
- Base score: 40%
- Budget compatibility: 25%
- Location compatibility: 20%
- Sleep schedule compatibility: 15%
- Pets compatibility: 10%
- **Common liked listings: 15%** (NEW)

The common likes score is calculated based on the ratio of common likes to total unique likes between two users.

## Controllers

### ListingsController

New actions:
- `like` - Like a listing
- `unlike` - Unlike a listing
- `explore` - Browse random published/verified listings

### MatchesController

New action:
- `liked_listings` - View listings liked by matched users, grouped by which matches liked them

## Routes

```ruby
# Listings
resources :listings do
  collection do
    get :explore
  end
  member do
    post :like
    delete :unlike
  end
end

# Matches
resources :matches do
  collection do
    get :liked_listings
  end
end
```

## Views

### New Views

1. **Explore Page** (`listings/explore.html.erb`)
   - Shows random published/verified listings
   - Not tied to matches
   - Available to all logged-in users

2. **What Your Matches Liked** (`matches/liked_listings.html.erb`)
   - Shows listings liked by matched users
   - Displays which matches liked each listing
   - Empty state with helpful links if no matches have liked anything

### Updated Views

1. **Listing Show Page** (`listings/show.html.erb`)
   - Added Like/Unlike button
   - Button shows different states based on whether user has liked the listing
   - Only visible to logged-in users

2. **Matches Index Page** (`matches/index.html.erb`)
   - Added "What Your Matches Liked" button

3. **Header Navigation** (`shared/_header.html.erb`)
   - Added "Explore" link
   - Added "Matches" link

## User Experience

### Liking a Listing

1. User views a listing
2. Clicks "Like" button
3. Listing is added to their liked listings
4. Button changes to "Unlike"

### Viewing Matches' Liked Listings

1. User navigates to Matches page
2. Clicks "What Your Matches Liked"
3. Sees listings liked by their matches
4. Can see which specific matches liked each listing
5. Can click through to view full listing details

### Exploring Listings

1. User clicks "Explore" in navigation
2. Sees random selection of published/verified listings
3. Can like listings directly from this view
4. Independent of matching system

## Testing

### Factory

```ruby
FactoryBot.define do
  factory :liked_listing do
    association :user
    association :listing
  end
end
```

### Test Scenarios

1. User can like a listing
2. User can unlike a listing
3. User cannot like the same listing twice
4. Matched users with common liked listings get higher compatibility scores
5. Users can see listings liked by their matches
6. Explore page shows random listings
7. Like/Unlike buttons appear correctly based on authentication and like status

## Migration

To apply these changes, run:

```bash
bin/rails db:migrate
```

## Future Enhancements

Potential improvements:
- Add notification when a match likes the same listing you liked
- Show "mutual interest" badge on listings both users liked
- Filter matches' liked listings by location or price
- Show trending listings (most liked by matches)
- Add analytics on which types of listings users' matches prefer

