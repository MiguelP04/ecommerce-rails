class CreateOptions < ActiveRecord::Migration[7.2]
  def change
    create_table :options do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :options, :name, unique: true
  end
end
