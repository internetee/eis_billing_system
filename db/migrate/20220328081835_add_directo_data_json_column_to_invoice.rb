class AddDirectoDataJsonColumnToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :directo_data, :jsonb, null: true
  end
end
