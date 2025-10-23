rails db:reset
    drops current database, recreates it, runs migrations, seeds it with data

rails db:seed
    run seed file

rails db:drop 
    drops tables

rails db:create

rails console
    <model>.count

    u = User.first
    u.listings
    u.listings.first.title
