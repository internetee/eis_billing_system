class CreateReferences < ActiveRecord::Migration[6.1]
  def change
    create_table :references do |t|
      t.integer :reference_number
      t.string :initiator

      t.timestamps
    end

    add_index :references, :reference_number, unique: true
  end
end
