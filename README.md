# RoomMate – CS-UY 4513 Team 5 (Fall 2025)

[![CI](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/ci.yml/badge.svg)](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/ci.yml) [![Deploy to Heroku](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/deploy.yml/badge.svg)](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/deploy.yml)


RoomMate ([Room-Mate.app](https://Room-Mate.app/)) is a SaaS platform that helps students and newcomers find compatible roommates and share housing costs.

[![1765207234724](docs/image/1765207234724.png)](https://Room-Mate.app/)

- Build secure user profiles with lifestyle, budget, and housing preferences
- Match seekers and listers with a compatibility engine and verified listings
- Coordinate through messaging while persisting preferences, history, and matches

## Key Features
- Search active listings by city, price band, and free-text keywords
- Flag listings for community verification and surface a “Verified” badge once approved
- Maintain listing state via statuses (`pending`, `published`, `Verified`) so staff can gate what members see

Detailed requirements live in [Project_Specification](docs/Project_Specification.md).

Features in [Features](docs/features.md)

Contacts in [Contacts](docs/contacts.md)

## Stack
- Language: Ruby 3.3.8, HTML, CSS
- Framework: Ruby on Rails 7
- Database: PostgreSQL (Production), SQLite (Development)
- Testing:
  - Unit & request: RSpec
  - System/acceptance: Cucumber, Capybara (search + listing verification flows today)

## Getting Started
```bash
bundle install
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails server
```

### CI/CD
```bash
bundle exec rspec
bundle exec cucumber
```

### deployment via Heroku (pre-configured in repo)
```bash
git push heroku main
```


## Testing
- TDD & BDD: `bundle exec rspec` & `bundle exec cucumber`

## Helpful Links
- [GitHub](https://github.com/depasqua/cs-uy-4513-f25-team5)
- [Project Specification](docs/Project_Specification.md)
- [Ed Discussion](https://edstem.org/us/courses/85791/discussion/6967668)
- [Brightspace](https://brightspace.nyu.edu/d2l/le/lessons/479123)
- [Google Drive](https://drive.google.com/drive/folders/1_f-VSSiocMMotoAsxXHAGuWwao9Dp3jI)
- [Google Chat Room](https://chat.google.com/room/AAQA1jtdT-k?cls=7)
- [Heroku Configuration](https://dashboard.heroku.com/apps/roommate-app)
- [Room-Mate.app Link: https://room-mate.app/](https://room-mate.app/)
 
 
