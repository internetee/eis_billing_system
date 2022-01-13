class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.datetime :issue_date
      t.datetime :due_date
      t.datetime :e_invoice_sent_at # ????
      t.datetime :cancelled_at # ?????

      t.string :description
      t.string :currency
      t.string :invoice_number
      t.string :transaction_amount
      t.string :order_reference # ?????
      t.string :reference_number

      t.string :seller_name
      t.string :seller_reg_no
      t.string :seller_iban
      t.string :seller_bank
      t.string :seller_swift
      t.string :seller_vat_no
      t.string :seller_country_code
      t.string :seller_state
      t.string :seller_street
      t.string :seller_city
      t.string :seller_zip
      t.string :seller_phone
      t.string :seller_url
      t.string :seller_email
      t.string :seller_contact_name

      t.references :user, index: true
      t.string :buyer_name
      t.string :buyer_reg_no
      t.string :buyer_vat_no # ?????
      t.string :buyer_country_code
      t.string :buyer_state
      t.string :buyer_street
      t.string :buyer_city
      t.string :buyer_zip
      t.string :buyer_phone
      t.string :buyer_url
      t.string :buyer_email
      t.string :buyer_iban # ?????

      t.string :vat_rate # ?????
      t.jsonb :items_attributes # ???

      t.integer :status

      t.timestamps
    end
  end
end
