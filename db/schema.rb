# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_29_214054) do
  create_table "avatars", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "image_base64", null: false
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_avatars_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.string "city"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_email"
    t.string "status"
    t.boolean "verification_requested", default: false
    t.boolean "verified", default: false
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "reporter_id", null: false
    t.integer "reported_user_id", null: false
    t.string "report_type", null: false
    t.text "description"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_user_id"], name: "index_reports_on_reported_user_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.text "bio"
    t.integer "budget"
    t.string "preferred_location"
    t.string "sleep_schedule"
    t.string "pets"
    t.string "housing_status"
    t.string "contact_visibility"
    t.string "role"
    t.boolean "suspended", default: false
  end

  add_foreign_key "avatars", "users"
  add_foreign_key "listings", "users"
  add_foreign_key "reports", "users", column: "reported_user_id"
  add_foreign_key "reports", "users", column: "reporter_id"
end
