class CreateVariantOptionValues < ActiveRecord::Migration[7.2]
  def change
    create_table :variant_option_values do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :option_value, null: false, foreign_key: true

      t.timestamps
    end
    add_index :variant_option_values, [ :product_variant_id, :option_value_id ],
              unique: true,
              name: "index_variant_option_uniqueness"
  end
end
