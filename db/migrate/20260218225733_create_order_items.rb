class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
