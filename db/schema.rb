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

ActiveRecord::Schema[7.0].define(version: 2022_11_25_090844) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.bigint "revision_id"
    t.integer "user_id"
    t.string "user_name"
    t.string "user_type"
    t.integer "action", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revision_id"], name: "index_audits_on_revision_id"
  end

  create_table "case_reports", force: :cascade do |t|
    t.integer "incident_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "revisions", force: :cascade do |t|
    t.bigint "case_report_id"
    t.date "incident_date"
    t.datetime "incident_datetime"
    t.string "report_type"
    t.string "responder_name"
    t.string "patient_name"
    t.date "patient_dob"
    t.jsonb "incident_address"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_report_id"], name: "index_revisions_on_case_report_id"
  end

  add_foreign_key "audits", "revisions"
  add_foreign_key "revisions", "case_reports"
end
