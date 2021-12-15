class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.string :invoice_number
      t.string :description
      t.string :transaction_amount
      t.string :order_reference
      t.string :reference_number
      t.string :customer_name
      t.string :customer_email
      t.integer :status
      t.references :user, index: true

      t.timestamps
    end
  end
end
