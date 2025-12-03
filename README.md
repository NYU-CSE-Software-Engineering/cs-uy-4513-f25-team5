# RoomMate – CS-UY 4513 Team 5 (Fall 2025)

[![CI](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/ci.yml/badge.svg)](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/ci.yml) [![Deploy to Heroku](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/deploy.yml/badge.svg)](https://github.com/NYU-CSE-Software-Engineering/cs-uy-4513-f25-team5/actions/workflows/deploy.yml)

RoomMate is a SaaS platform that helps students and newcomers find compatible roommates and share housing costs.

- Build secure user profiles with lifestyle, budget, and housing preferences
- Match seekers and listers with a compatibility engine and verified listings
- Coordinate through messaging while persisting preferences, history, and matches

## Key Features
- Search active listings by city, price band, and free-text keywords
- Flag listings for community verification and surface a “Verified” badge once approved
- Maintain listing state via statuses (`pending`, `published`, `Verified`) so staff can gate what members see

Detailed requirements live in [Project_Specification](docs/Project_Specification.md).

Features in [Features](docs/features.md)

## Contacts

**Instructor**
- Peter DePasquale [@depasqua](https://github.com/depasqua)
- Email: [pd80@nyu.edu](mailto:pd80@nyu.edu)
- Office: 370 Jay Street, Rm 866
- Office hours: Mondays & Wednesdays 1–3 pm (in-person); Tuesdays 1–2 pm (Zoom); Thursdays 1–3 pm (Zoom)
- [Schedule office hours](https://calendly.com/depasquale-cse/office-hours)

**TA**
- Taaha Bin Mohsin [@Taaha](https://github.com/taahamohsin)
- Email: [tb3486@nyu.edu](mailto:tb3486@nyu.edu)
- Office: Jacobs Rm 223
- Office hours: Tuesdays & Thursdays, 12:30–3:30 pm

## Team

**Team Lead**
- Moayad Alismail [@MoayadAlismail](https://github.com/MoayadAlismail)

**Developers**
- Drastansh Nadola [@Drastansh7](https://github.com/Drastansh7)
- Eric Ma [@mAE7777](https://github.com/mAE7777)
- Kevin Aguirre [@Kevin-Aguirre](https://github.com/Kevin-Aguirre)
- Steven Li [@StevenLi-phoenix](https://github.com/StevenLi-phoenix)
- Terry Li [@turtlelyte](https://github.com/turtlelyte)
- Tianyi Xu [@tianyix033](https://github.com/tianyix033)

## Stack
- Language: Ruby 3.3.8, HTML, CSS
- Framework: Ruby on Rails 7
- Database: PostgreSQL
- Testing:
  - Unit & request: RSpec
  - System/acceptance: Cucumber, Capybara (search + listing verification flows today)

## Getting Started
```bash
# ensure your shell loads rbenv shims
eval "$(rbenv init - zsh)"   # or "- bash" for Bash users

rbenv install 3.3.8       # once per machine
rbenv local 3.3.8         # ensures this version for the repo
bundle install
bin/rails db:prepare
bin/rails server
```

Use `bin/rails db:prepare` for day-to-day work; run `bundle exec rails db:setup` on a fresh machine to create, migrate, and seed everything in one shot. The seeds create listings with valid statuses and owner emails so the verification UI has data to demonstrate.

## Testing
- Unit/request suite: `bundle exec rspec`
- Acceptance flows (search + verification): `bundle exec cucumber`
  - By default, `cucumber.yml` limits runs to `features/search_listings.feature` and `features/verify_listings.feature`
  - To run the focused profile explicitly (CI equivalent): `bundle exec cucumber features/search_listings.feature features/verify_listings.feature`
  - Provide paths for any additional `.feature` files you add later.

## Helpful Links
- [GitHub](https://github.com/depasqua/cs-uy-4513-f25-team5)
- [Project Specification](docs/Project_Specification.md)
- [Ed Discussion](https://edstem.org/us/courses/85791/discussion/6967668)
- [Brightspace](https://brightspace.nyu.edu/d2l/le/lessons/479123)
- [Google Drive](https://drive.google.com/drive/folders/1_f-VSSiocMMotoAsxXHAGuWwao9Dp3jI)
- [Google Chat Room](https://chat.google.com/room/AAQA1jtdT-k?cls=7)
 

