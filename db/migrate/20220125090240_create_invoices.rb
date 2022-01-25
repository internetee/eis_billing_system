class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.string :invoice_number
      t.string :initiator
      t.string :payment_reference
      t.string :transaction_amount

      t.timestamps
    end
  end
end
