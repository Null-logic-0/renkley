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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_031750) do
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

  create_table "brand_aliases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_brand_aliases_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_brand_aliases_on_organization_id"
  end

  create_table "citations", force: :cascade do |t|
    t.integer "authority_score", default: 0, null: false
    t.integer "competitor_share_pct", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.bigint "last_scan_id"
    t.integer "mentions_count", default: 0, null: false
    t.bigint "organization_id", null: false
    t.integer "trend", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "your_share_pct", default: 0, null: false
    t.index ["last_scan_id"], name: "index_citations_on_last_scan_id"
    t.index ["organization_id", "domain"], name: "index_citations_on_organization_id_and_domain", unique: true
    t.index ["organization_id"], name: "index_citations_on_organization_id"
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

  create_table "competitor_snapshots", force: :cascade do |t|
    t.integer "citations_count", default: 0, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "scan_id", null: false
    t.integer "score", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_competitor_snapshots_on_company_id"
    t.index ["scan_id", "company_id"], name: "index_competitor_snapshots_on_scan_id_and_company_id", unique: true
    t.index ["scan_id"], name: "index_competitor_snapshots_on_scan_id"
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
    t.string "category"
    t.datetime "created_at", null: false
    t.string "default_ai_platform"
    t.string "name", null: false
    t.integer "onboarding_status", default: 0, null: false
    t.integer "onboarding_step", default: 1, null: false
    t.integer "scan_frequency", default: 1, null: false
    t.string "slug", null: false
    t.string "time_zone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "platform_snapshots", force: :cascade do |t|
    t.bigint "ai_platform_id", null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.integer "mentions_count", default: 0, null: false
    t.string "rank_label", null: false
    t.bigint "scan_id", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility_pct", default: 0, null: false
    t.index ["ai_platform_id"], name: "index_platform_snapshots_on_ai_platform_id"
    t.index ["company_id"], name: "index_platform_snapshots_on_company_id"
    t.index ["scan_id", "ai_platform_id", "company_id"], name: "index_platform_snapshots_on_scan_platform_company", unique: true
    t.index ["scan_id"], name: "index_platform_snapshots_on_scan_id"
  end

  create_table "prompt_results", force: :cascade do |t|
    t.bigint "ai_platform_id", null: false
    t.datetime "created_at", null: false
    t.bigint "prompt_id", null: false
    t.bigint "scan_id", null: false
    t.bigint "top_competitor_company_id"
    t.datetime "updated_at", null: false
    t.bigint "winner_company_id", null: false
    t.integer "your_position"
    t.index ["ai_platform_id"], name: "index_prompt_results_on_ai_platform_id"
    t.index ["prompt_id"], name: "index_prompt_results_on_prompt_id"
    t.index ["scan_id", "prompt_id"], name: "index_prompt_results_on_scan_id_and_prompt_id", unique: true
    t.index ["scan_id"], name: "index_prompt_results_on_scan_id"
    t.index ["top_competitor_company_id"], name: "index_prompt_results_on_top_competitor_company_id"
    t.index ["winner_company_id"], name: "index_prompt_results_on_winner_company_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "search_volume", default: 1, null: false
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_prompts_on_organization_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "effort", default: 1, null: false
    t.integer "impact_score", default: 5, null: false
    t.bigint "organization_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.text "rationale", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_recommendations_on_organization_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "frequency", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.string "report_kind", null: false
    t.integer "tag", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_reports_on_organization_id"
  end

  create_table "scans", force: :cascade do |t|
    t.decimal "citation_share_pct", precision: 5, scale: 1
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "mentions_count"
    t.bigint "organization_id", null: false
    t.integer "overall_score"
    t.integer "ranking_position"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_scans_on_organization_id"
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

  add_foreign_key "brand_aliases", "organizations"
  add_foreign_key "citations", "organizations"
  add_foreign_key "citations", "scans", column: "last_scan_id"
  add_foreign_key "companies", "organizations"
  add_foreign_key "competitor_snapshots", "companies"
  add_foreign_key "competitor_snapshots", "scans"
  add_foreign_key "onboarding_tasks", "organizations"
  add_foreign_key "platform_snapshots", "ai_platforms"
  add_foreign_key "platform_snapshots", "companies"
  add_foreign_key "platform_snapshots", "scans"
  add_foreign_key "prompt_results", "ai_platforms"
  add_foreign_key "prompt_results", "companies", column: "top_competitor_company_id"
  add_foreign_key "prompt_results", "companies", column: "winner_company_id"
  add_foreign_key "prompt_results", "prompts"
  add_foreign_key "prompt_results", "scans"
  add_foreign_key "prompts", "organizations"
  add_foreign_key "recommendations", "organizations"
  add_foreign_key "reports", "organizations"
  add_foreign_key "scans", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "organizations"
end
