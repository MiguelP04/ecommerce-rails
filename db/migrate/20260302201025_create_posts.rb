class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
