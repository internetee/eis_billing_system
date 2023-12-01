class AddLinkpayInfoToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :linkpay_info, :jsonb, default: {}, null: true
  end
end
