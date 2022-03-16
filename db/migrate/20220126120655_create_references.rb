class CreateReferences < ActiveRecord::Migration[6.1]
  def change
    create_table :references do |t|
      t.string :reference_number, null: false
      t.string :initiator, null: false

      t.timestamps
    end

    # add_index :references, :reference_number, unique: true
  end
end
