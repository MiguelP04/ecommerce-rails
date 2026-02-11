class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :google_uid, null: false
      t.string :email
      t.string :name
      t.jsonb :avatar_url
      t.string :jti, null: false

      t.timestamps
    end

    add_index :users, :google_uid, unique: true
    add_index :users, :jti, unique: true
  end
end
