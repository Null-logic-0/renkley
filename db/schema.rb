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

ActiveRecord::Schema[8.1].define(version: 2026_07_24_092142) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ai_platforms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_ai_platforms_on_key", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.integer "kind", default: 0, null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "domain"], name: "index_companies_on_organization_id_and_domain", unique: true
    t.index ["organization_id"], name: "index_companies_on_organization_id"
  end

  create_table "onboarding_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.string "key", null: false
    t.string "label", null: false
    t.bigint "organization_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "key"], name: "index_onboarding_tasks_on_organization_id_and_key", unique: true
    t.index ["organization_id"], name: "index_onboarding_tasks_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "onboarding_status", default: 0, null: false
    t.integer "onboarding_step", default: 1, null: false
    t.string "slug", null: false
    t.string "time_zone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "prompts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_prompts_on_organization_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.bigint "organization_id", null: false
    t.string "password_digest", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "companies", "organizations"
  add_foreign_key "onboarding_tasks", "organizations"
  add_foreign_key "prompts", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
end
