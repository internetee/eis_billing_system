class AddDescriptionColumnToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :description, :string, null: true
  end
end
