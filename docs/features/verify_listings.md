# Verify Listings

## User Story
As a Community Verifier, I want to review pending housing listings and mark trustworthy ones as verified so that members can trust the marketplace.

## Acceptance Criteria
1. Pending listings flagged with `verification_requested: true` show up on the verification requests page with links to their detail pages.
2. Selecting “Mark as Verified” updates the listing status to `Verified`, sets `verified: true`, and surfaces a “Verified” badge on both the verification list and the public listing page.
3. Listings without a verification request never appear in the queue, and unverified listings never render a badge on their public page.

## MVC Outline

### Models
- `Listing`
  - attributes: `title`, `description`, `price`, `city`, `status`, `owner_email`, `verification_requested`, `verified`
  - validations: presence and status inclusion as described in [Search Listings](./search_listings.md)
  - scopes: `pending_verification` (filters by `verification_requested: true`)
  - methods: `mark_as_verified!` to transition status and flip the `verified` flag

### Views
- `verification_requests/index.html.erb`
  - Lists all pending verification requests
  - Displays a “Verified” badge inline once a listing has been approved
- `listings/show.html.erb`
  - Renders the badge and verification call-to-action button

### Controllers
- `VerificationRequestsController#index`
  - Loads `Listing.pending_verification.order(:created_at)`
- `VerificationRequestsController#verify`
  - Calls `mark_as_verified!` and redirects back to the queue
- `ListingsController#show`
  - Displays metadata plus the verification button when appropriate

### Routes
```ruby
resources :verification_requests, only: [:index]
resources :listings, only: [:show] do
  member do
    patch :verify, to: 'verification_requests#verify'
  end
end
```

### Additional Notes
- Seeds create listings with `owner_email`, `status`, and `verification_requested` flags so the verification queue has demo data after `bundle exec rails db:setup`.
- Keep the list of allowed statuses (`pending`, `published`, `Verified`) in sync with the constants defined in `Listing`.
