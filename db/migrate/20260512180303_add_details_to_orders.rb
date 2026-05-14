class AddDetailsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_reference :orders, :address, foreign_key: true
    add_column :orders, :payment_method, :string
    add_column :orders, :notes, :text
  end
end
