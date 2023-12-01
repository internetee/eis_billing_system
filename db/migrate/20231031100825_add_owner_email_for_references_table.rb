class AddOwnerEmailForReferencesTable < ActiveRecord::Migration[7.0]
  def change
    add_column :references, :email, :string
  end
end
