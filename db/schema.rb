# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130607100949) do

  create_table "transactions", :force => true do |t|
    t.string   "token"
    t.string   "payer_id"
    t.float    "value"
    t.string   "transaction_id"
    t.string   "payment_state"
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "transactions", ["payer_id"], :name => "index_transactions_on_payer_id"
  add_index "transactions", ["product_id"], :name => "index_transactions_on_product_id"
  add_index "transactions", ["token"], :name => "index_transactions_on_token"
  add_index "transactions", ["transaction_id"], :name => "index_transactions_on_transaction_id", :unique => true

end
