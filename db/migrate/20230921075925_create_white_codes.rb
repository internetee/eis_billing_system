class CreateWhiteCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :white_codes do |t|
      t.string :code, null: false

      t.timestamps
    end
  end
end
