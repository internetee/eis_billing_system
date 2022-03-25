class AddTransactionTimeToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :transaction_time, :datetime, null: true
  end
end
