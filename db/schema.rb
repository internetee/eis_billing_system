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

ActiveRecord::Schema.define(version: 2022_01_31_124437) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invoices", force: :cascade do |t|
    t.integer "invoice_number"
    t.string "initiator"
    t.string "payment_reference"
    t.string "transaction_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
  end

  create_table "references", force: :cascade do |t|
    t.integer "reference_number"
    t.string "initiator"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reference_number"], name: "index_references_on_reference_number", unique: true
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

end
