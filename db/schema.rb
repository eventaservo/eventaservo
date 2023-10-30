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

ActiveRecord::Schema[7.0].define(version: 2023_10_29_133126) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ads", force: :cascade do |t|
    t.bigint "event_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["event_id"], name: "index_ads_on_event_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time", precision: nil
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at", precision: nil
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code"
    t.string "continent"
    t.index ["continent"], name: "index_countries_on_continent"
    t.index ["name", "continent"], name: "index_countries_on_name_and_continent"
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "event_redirections", force: :cascade do |t|
    t.string "old_short_url", null: false
    t.string "new_short_url", null: false
    t.integer "hits", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["old_short_url"], name: "index_event_redirections_on_old_short_url", unique: true
  end

  create_table "event_reports", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "title"
    t.string "url", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_reports_on_event_id"
    t.index ["user_id"], name: "index_event_reports_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", limit: 400
    t.text "content"
    t.string "address"
    t.text "city"
    t.integer "country_id", null: false
    t.integer "user_id", null: false
    t.datetime "date_start", precision: nil, null: false
    t.datetime "date_end", precision: nil
    t.string "code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "site"
    t.string "email"
    t.boolean "deleted", default: false, null: false
    t.float "latitude"
    t.float "longitude"
    t.boolean "online", default: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "time_zone", default: "Etc/UTC", null: false
    t.string "import_url", limit: 400
    t.string "specolisto", default: "Kunveno"
    t.string "short_url"
    t.boolean "cancelled", default: false
    t.text "cancel_reason"
    t.jsonb "metadata"
    t.boolean "international_calendar", default: false
    t.integer "participants_count", default: 0
    t.boolean "display_flag", default: true
    t.index "md5(content)", name: "index_events_on_content"
    t.index ["address"], name: "index_events_on_address"
    t.index ["cancelled"], name: "index_events_on_cancelled"
    t.index ["city"], name: "index_events_on_city"
    t.index ["date_end"], name: "index_events_on_date_end"
    t.index ["date_start"], name: "index_events_on_date_start"
    t.index ["deleted"], name: "index_events_on_deleted"
    t.index ["description"], name: "index_events_on_description"
    t.index ["online"], name: "index_events_on_online"
    t.index ["participants_count"], name: "index_events_on_participants_count"
    t.index ["specolisto"], name: "index_events_on_specolisto"
    t.index ["title"], name: "index_events_on_title"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "followers", force: :cascade do |t|
    t.string "followable_type", null: false
    t.bigint "followable_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["followable_type", "followable_id"], name: "index_followers_on_followable_type_and_followable_id"
    t.index ["user_id"], name: "index_followers_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "text"
    t.bigint "user_id", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text"], name: "index_logs_on_text"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "notification_lists", force: :cascade do |t|
    t.integer "country_id", null: false
    t.string "email", null: false
    t.string "code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_notification_lists_on_code"
    t.index ["country_id", "email"], name: "index_notification_lists_on_country_id_and_email"
  end

  create_table "organization_events", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "event_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_organization_events_on_event_id"
    t.index ["organization_id"], name: "index_organization_events_on_organization_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["admin"], name: "index_organization_users_on_admin"
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.boolean "official", default: false
    t.string "logo"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "email"
    t.string "url"
    t.integer "country_id", default: 99999
    t.string "city"
    t.string "address"
    t.string "phone"
    t.boolean "partner", default: false
    t.boolean "major", default: false
    t.string "youtube"
    t.boolean "display_flag", default: true
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["short_name"], name: "index_organizations_on_short_name"
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "public", default: false
    t.index ["event_id"], name: "index_participants_on_event_id"
    t.index ["public"], name: "index_participants_on_public"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "timezones", force: :cascade do |t|
    t.string "en", null: false
    t.string "eo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false
    t.string "name"
    t.string "image"
    t.string "provider"
    t.string "uid"
    t.string "avatar"
    t.string "city"
    t.integer "country_id", default: 99999
    t.string "username"
    t.jsonb "mailings"
    t.string "authentication_token", limit: 30
    t.date "birthday"
    t.string "ueacode"
    t.string "about"
    t.jsonb "ligiloj", default: {}, null: false
    t.jsonb "instruo", default: {}, null: false
    t.jsonb "prelego", default: {}, null: false
    t.string "jwt_token"
    t.boolean "disabled", default: false
    t.boolean "system_account", default: false
    t.integer "events_count", default: 0
    t.string "webcal_token"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["disabled"], name: "index_users_on_disabled"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["events_count"], name: "index_users_on_events_count"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  create_table "videos", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "url", null: false
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "logs", "users"
end
