class AddJsonFieldToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :invoice_items, :jsonb
  end
end
