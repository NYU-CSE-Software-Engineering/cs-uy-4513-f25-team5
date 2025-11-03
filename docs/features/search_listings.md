# Search Listings

## User Story
As a room seeker, I want to search for housing listings by various criteria such as location, price, and keywords so that I can find my ideal residence efficiently.

## Acceptance Criteria
1. A signed-in user can search for listings by city name and see all matching results displayed with their basic information (title, price, city).
2. A signed-in user can search for listings within a specific price range and see only listings that fall within that range.
3. A signed-in user can search for listings using keywords that match listing titles or descriptions and see relevant results.
4. A signed-in user can combine multiple search filters (city, price range, keywords) to find listings that match all criteria.
5. When no listings match the search criteria, the user sees a clear message indicating no results were found.
6. A signed-in user's search history is saved, allowing them to view and reuse previous searches.

## MVC Outline

### Models
- `Listing`
  - attributes: `title:string`, `description:text`, `price:decimal`, `city:string`, `user_id:integer`
  - validations: presence of `title`, `price`, `city`
  - methods: Search scopes for filtering by city, price range, and keywords

- `SearchHistory` (may be needed for future implementation)
  - attributes: `user_id:integer`, `city:string`, `min_price:decimal`, `max_price:decimal`, `keywords:string`, `searched_at:datetime`
  - associations: `belongs_to :user`

### Views
- `listings/search.html.erb` (search form and results page)
- Displays search form with fields for city, price range, and keywords
- Shows search results in a list format with listing details
- Displays "No results found" message when applicable

### Controllers
- `ListingsController` with `search` action for displaying search form and results
  - Handles search query parameters (city, min_price, max_price, keywords)
  - Filters listings based on search criteria
  - Saves search to history if user is signed in

### Routes
Aligned with Project Specification API (Section 2.5):

```ruby
# Search route (matching /search/listings endpoint in spec)
get    '/search/listings', to: 'listings#search'     # Search for listings
```

The same route serves both the web interface and API, accepting query parameters for filtering (city, min_price, max_price, keywords).

### Search Functionality
- Filter by city (exact match or case-insensitive)
- Filter by price range (min_price and max_price)
- Search by keywords in title and description (case-insensitive, partial matches)
- Combine all filters (AND logic - all criteria must match)
- Results should be ordered by most recent first (created_at DESC)

### Associations
```ruby
class Listing < ApplicationRecord
  belongs_to :user
  
  # Search scopes
  scope :by_city, ->(city) { where('city ILIKE ?', "%#{city}%") }
  scope :in_price_range, ->(min, max) { where(price: min..max) }
  scope :with_keywords, ->(keywords) { 
    where('title ILIKE ? OR description ILIKE ?', "%#{keywords}%", "%#{keywords}%") 
  }
end
```

