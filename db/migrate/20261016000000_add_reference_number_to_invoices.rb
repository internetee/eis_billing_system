class AddReferenceNumberToInvoices < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :invoices, :reference_number, :string
    add_index :invoices, :reference_number, unique: true, where: 'reference_number IS NOT NULL',
                                            algorithm: :concurrently
  end
end
