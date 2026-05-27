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

ActiveRecord::Schema[8.1].define(version: 2022_06_29_152206) do
  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "document_id"
    t.string "document_type"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.string "user_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "geo_monitor_layers", force: :cascade do |t|
    t.string "access"
    t.boolean "active"
    t.string "bbox"
    t.string "checktype"
    t.datetime "created_at", precision: nil, null: false
    t.string "institution"
    t.string "layername"
    t.string "rights"
    t.string "slug"
    t.integer "statuses_count"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.index ["active"], name: "index_geo_monitor_layers_on_active"
    t.index ["slug"], name: "index_geo_monitor_layers_on_slug"
  end

  create_table "geo_monitor_statuses", force: :cascade do |t|
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.integer "layer_id"
    t.string "res_code"
    t.string "res_headers"
    t.decimal "res_time"
    t.text "submitted_query"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["layer_id"], name: "index_geo_monitor_statuses_on_layer_id"
  end

  create_table "searches", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "query_params"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "guest", default: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
