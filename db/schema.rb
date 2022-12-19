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

ActiveRecord::Schema[7.0].define(version: 2022_12_15_102132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.bigint "revision_id"
    t.integer "user_id"
    t.string "user_name"
    t.string "user_type"
    t.integer "action", limit: 2
    t.datetime "action_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["revision_id"], name: "index_audits_on_revision_id"
  end

  create_table "case_reports", force: :cascade do |t|
    t.integer "incident_number"
    t.datetime "incident_at", default: -> { "CURRENT_TIMESTAMP" }
    t.integer "datacenter_id", null: false
    t.integer "incident_id", null: false
    t.index ["incident_id"], name: "index_case_reports_on_incident_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.bigint "case_report_id"
    t.integer "user_id"
    t.string "responder_name"
    t.string "patient_name"
    t.date "patient_dob"
    t.jsonb "incident_address", default: "{}"
    t.jsonb "content", default: "{}"
    t.string "case_report_name", null: false
    t.index ["case_report_id"], name: "index_revisions_on_case_report_id"
  end

  add_foreign_key "audits", "revisions"
  add_foreign_key "revisions", "case_reports"

  create_view "case_reports_view", sql_definition: <<-SQL
      WITH recent_revisions AS (
           SELECT DISTINCT ON (revisions.case_report_id) revisions.case_report_id,
              revisions.id,
              revisions.case_report_name
             FROM revisions
            ORDER BY revisions.case_report_id, revisions.id DESC
          ), counts AS (
           SELECT revisions.case_report_id,
              count(*) AS revisions_count
             FROM revisions
            GROUP BY revisions.case_report_id
          )
   SELECT case_reports.id,
      case_reports.incident_number,
      case_reports.incident_id,
      case_reports.incident_at,
      case_reports.datacenter_id,
      recent_revisions.case_report_name,
      recent_revisions.id AS revision_id,
      counts.revisions_count,
          CASE
              WHEN (counts.revisions_count = 1) THEN 0
              ELSE 1
          END AS report_type
     FROM ((case_reports
       JOIN recent_revisions ON ((case_reports.id = recent_revisions.case_report_id)))
       JOIN counts ON ((case_reports.id = counts.case_report_id)));
  SQL
end
