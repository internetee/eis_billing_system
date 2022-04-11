class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.integer :invoice_number, null: false
      t.string :initiator, null: false
      t.string :payment_reference
      t.decimal :transaction_amount
      t.integer :status, default: 0, null: false, index: true
      t.jsonb :everypay_response, null: true
      t.jsonb :directo_data, null: true
      t.boolean :in_directo, default: false
      t.datetime :transaction_time, null: true

      t.timestamps
    end

    # add_index :invoices, :invoice_number, unique: true
  end
end
