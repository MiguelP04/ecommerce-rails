class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :street
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :phone
      t.boolean :is_default

      t.timestamps
    end
  end
end
