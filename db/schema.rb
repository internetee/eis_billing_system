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

ActiveRecord::Schema.define(version: 2023_01_18_113644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invoices", force: :cascade do |t|
    t.integer "invoice_number", null: false
    t.string "initiator", null: false
    t.string "payment_reference"
    t.decimal "transaction_amount"
    t.integer "status", default: 0, null: false
    t.jsonb "everypay_response"
    t.jsonb "directo_data"
    t.boolean "in_directo", default: false
    t.datetime "transaction_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.datetime "sent_at_omniva"
    t.integer "affiliation", default: 0
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "references", force: :cascade do |t|
    t.string "reference_number", null: false
    t.string "initiator", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "owner"
  end

  create_table "setting_entries", force: :cascade do |t|
    t.string "code", null: false
    t.string "value"
    t.string "group", null: false
    t.string "format", null: false
    t.string "creator_str"
    t.string "updator_str"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_setting_entries_on_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
