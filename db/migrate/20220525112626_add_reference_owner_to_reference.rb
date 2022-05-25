class AddReferenceOwnerToReference < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :owner, :string, null: true
  end
end
