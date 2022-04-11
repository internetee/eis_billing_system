class AddSentAtOmnivaToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :sent_at_omniva, :datetime, null: true
  end
end
