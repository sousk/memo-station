# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "article_view_logs", :force => true do |t|
    t.integer  "article_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
    t.string   "subject"
    t.string   "url"
    t.text     "body"
    t.integer  "access_count",  :default => 0
    t.datetime "access_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "modified_at"
    t.datetime "url_access_at"
  end

  create_table "bars", :force => true do |t|
    t.text "body"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tags_articles", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "tag_id"
  end

  create_table "user_infos", :force => true do |t|
    t.integer  "user_id",      :limit => 10, :default => 0,  :null => false
    t.string   "name_kanji1",                :default => "", :null => false
    t.string   "name_kanji2",                :default => "", :null => false
    t.string   "pc_email",                   :default => "", :null => false
    t.string   "mobile_email",               :default => "", :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "karma",                      :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "loginname",  :default => "",    :null => false
    t.string   "password",   :default => "",    :null => false
    t.boolean  "deleted",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
