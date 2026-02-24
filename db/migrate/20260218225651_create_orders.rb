class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total, precision: 10, scale: 2, default: 0
      t.integer :status, default: 0 # 0: pending, 1: paid, 2: shipped, 3: cancelled

      t.timestamps
    end
  end
end
