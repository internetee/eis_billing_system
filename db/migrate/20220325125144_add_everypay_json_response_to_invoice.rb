class AddEverypayJsonResponseToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :everypay_response, :jsonb, null: true
  end
end
