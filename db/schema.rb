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

ActiveRecord::Schema[7.1].define(version: 2025_11_19_203245) do
  create_table "active_matches", force: :cascade do |t|
    t.integer "user_one_id", null: false
    t.integer "user_two_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_one_id", "user_two_id"], name: "index_active_matches_on_user_one_id_and_user_two_id", unique: true
    t.index ["user_one_id"], name: "index_active_matches_on_user_one_id"
    t.index ["user_two_id"], name: "index_active_matches_on_user_two_id"
  end

  create_table "avatars", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "image_base64", null: false
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_avatars_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "participant_one_id", null: false
    t.integer "participant_two_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_one_id", "participant_two_id"], name: "idx_on_participant_one_id_participant_two_id_34e343b89f", unique: true
    t.index ["participant_one_id"], name: "index_conversations_on_participant_one_id"
    t.index ["participant_two_id"], name: "index_conversations_on_participant_two_id"
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

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
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

  add_foreign_key "active_matches", "users", column: "user_one_id"
  add_foreign_key "active_matches", "users", column: "user_two_id"
  add_foreign_key "avatars", "users"
  add_foreign_key "conversations", "users", column: "participant_one_id"
  add_foreign_key "conversations", "users", column: "participant_two_id"
  add_foreign_key "listings", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
end
