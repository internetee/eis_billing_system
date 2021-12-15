class CreateBankStatements < ActiveRecord::Migration[6.1]
  def change
    create_table :bank_statements do |t|
      t.string :bank_code
      t.string :iban
      t.datetime :queried_at
      t.timestamps
    end
  end
end
