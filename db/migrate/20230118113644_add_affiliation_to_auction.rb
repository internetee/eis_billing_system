class AddAffiliationToAuction < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :affiliation, :integer, default: 0
  end
end
