class CreateOptionValues < ActiveRecord::Migration[7.2]
  def change
    create_table :option_values do |t|
      t.references :option, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :option_values, [:option_id, :name], unique: true
  end
end
