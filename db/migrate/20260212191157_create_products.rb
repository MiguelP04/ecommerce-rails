class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.float :average_rating, default: 0.0
      t.boolean :active, default: true
      t.jsonb :metadata, default: {}
      t.string :slug, null: false

      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
