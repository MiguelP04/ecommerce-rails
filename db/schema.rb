# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_12_191157) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, null: false
    t.integer "stock", default: 0
    t.float "average_rating", default: 0.0
    t.boolean "active", default: true
    t.jsonb "metadata", default: {}
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "google_uid"
    t.string "email"
    t.string "name"
    t.jsonb "avatar_url"
    t.string "jti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
