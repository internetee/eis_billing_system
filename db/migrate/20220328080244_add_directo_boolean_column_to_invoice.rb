class AddDirectoBooleanColumnToInvoice < ActiveRecord::Migration[6.1]
  def up
    add_column :invoices, :in_directo, :boolean
    change_column_default :invoices, :in_directo, false
  end

  def down
    remove_column :invoices, :in_directo
  end
end
