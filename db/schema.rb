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

ActiveRecord::Schema[7.1].define(version: 2025_12_08_163458) do
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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
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
    t.string "primary_image_id"
    t.text "image_base64"
    t.string "filename"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "matched_user_id", null: false
    t.decimal "compatibility_score", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matched_user_id"], name: "index_matches_on_matched_user_id"
    t.index ["user_id", "matched_user_id"], name: "index_matches_on_user_id_and_matched_user_id", unique: true
    t.index ["user_id"], name: "index_matches_on_user_id"
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

  add_foreign_key "active_matches", "users", column: "user_one_id"
  add_foreign_key "active_matches", "users", column: "user_two_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "avatars", "users"
  add_foreign_key "conversations", "users", column: "participant_one_id"
  add_foreign_key "conversations", "users", column: "participant_two_id"
  add_foreign_key "listings", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "reports", "users", column: "reported_user_id"
  add_foreign_key "reports", "users", column: "reporter_id"
end
