class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.bigint :category_id, null: false
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 12, scale: 2, null: false
      t.integer :stock, default: 0
      t.float :average_rating, default: 0.0
      t.boolean :active, default: true
      t.jsonb :metadata, default: {}
      t.string :slug, null: false

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :category_id
  end
end
