class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :code
      t.string :reference_number

      t.integer :role

      t.timestamps
    end
  end
end
