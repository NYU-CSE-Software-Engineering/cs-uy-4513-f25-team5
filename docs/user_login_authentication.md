# User Login and Authentication

## User Story
As a student or newcomer to the city, I want to securely log in to my RoomMate account so that I can access my profile, view potential roommate matches, and manage my housing listings.

## Acceptance Criteria
1. An unregistered user can create a new account by providing a valid email and password. After successful registration, the account is persisted in the database and the user is automatically logged in and redirected to their dashboard.
2. A registered user can successfully log in with valid email and password credentials. Upon successful login, they are redirected to their dashboard and can access protected features.
3. A user attempting to log in with an invalid email or incorrect password receives an appropriate error message and remains on the login page.
4. A user attempting to register with an email that already exists in the system receives a validation error indicating the email is already taken.
5. A logged-in user can log out of their account. After logout, they cannot access protected features without logging in again.

## MVC Outline

### Models
- `User`
  - attributes: `email:string`, `password_digest:string` (using bcrypt for secure password storage)
  - validations: 
    - presence of `email` and `password`
    - uniqueness of `email` (case-insensitive)
    - valid email format
    - minimum password length (e.g., 6 characters)
  - methods: `authenticate` (provided by `has_secure_password`)

### Views
- `users/new.html.erb` (registration form)
- `sessions/new.html.erb` (login form)
- `users/dashboard.html.erb` (protected page shown after successful login)

### Controllers
- `UsersController` with `new` and `create` actions for registration
- `SessionsController` with `new`, `create`, and `destroy` actions for login/logout
- `ApplicationController` with helper methods like `current_user`, `logged_in?`, and `authorize` for authentication checks

### Routes
Aligned with Project Specification API (Section 2.5):

```ruby
# Authentication routes (matching /auth/* endpoints in spec)
post   '/auth/register',  to: 'users#create'        # Register new user
post   '/auth/login',     to: 'sessions#create'     # User login
post   '/auth/logout',    to: 'sessions#destroy'    # Logout user

# For web interface (views)
get    '/signup',   to: 'users#new'           # Registration form
get    '/login',    to: 'sessions#new'        # Login form
get    '/dashboard', to: 'users#dashboard'    # Protected dashboard page
```

Note: Web interface uses friendly URLs (/signup, /login) while API uses RESTful endpoints (/auth/register, /auth/login)

### Session Management
- Use Rails session storage to maintain user login state
- Store user ID in session upon successful login
- Clear session upon logout

