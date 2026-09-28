class AddPaymentLinkToInvoices < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :invoices, :due_date, :date
    add_column :invoices, :payment_link, :string
    add_column :invoices, :payment_link_uuid, :string
    add_column :invoices, :payment_link_provider, :string

    add_index :invoices, :payment_link_uuid, unique: true, algorithm: :concurrently
  end
end
