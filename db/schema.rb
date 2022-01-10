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

ActiveRecord::Schema.define(version: 2021_12_28_124601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_statements", force: :cascade do |t|
    t.string "bank_code"
    t.string "iban"
    t.datetime "queried_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "bank_statement_id"
    t.string "bank_reference"
    t.string "iban"
    t.string "currency"
    t.string "buyer_bank_code"
    t.string "buyer_iban"
    t.string "buyer_name"
    t.string "document_no"
    t.string "description"
    t.decimal "sum"
    t.string "reference_no"
    t.datetime "paid_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "issue_date"
    t.datetime "due_date"
    t.datetime "e_invoice_sent_at"
    t.datetime "cancelled_at"
    t.string "description"
    t.string "currency"
    t.string "invoice_number"
    t.string "transaction_amount"
    t.string "order_reference"
    t.string "reference_number"
    t.string "seller_name"
    t.string "seller_reg_no"
    t.string "seller_iban"
    t.string "seller_bank"
    t.string "seller_swift"
    t.string "seller_vat_no"
    t.string "seller_country_code"
    t.string "seller_state"
    t.string "seller_street"
    t.string "seller_city"
    t.string "seller_zip"
    t.string "seller_phone"
    t.string "seller_url"
    t.string "seller_email"
    t.string "seller_contact_name"
    t.bigint "user_id"
    t.string "buyer_name"
    t.string "buyer_reg_no"
    t.string "buyer_vat_no"
    t.string "buyer_country_code"
    t.string "buyer_state"
    t.string "buyer_street"
    t.string "buyer_city"
    t.string "buyer_zip"
    t.string "buyer_phone"
    t.string "buyer_url"
    t.string "buyer_email"
    t.string "buyer_iban"
    t.string "vat_rate"
    t.jsonb "items_attributes"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "invoice_items"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "code"
    t.string "reference_number"
    t.integer "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
