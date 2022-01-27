class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.integer :invoice_number
      t.string :initiator
      t.string :payment_reference
      t.string :transaction_amount

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
  end
end
