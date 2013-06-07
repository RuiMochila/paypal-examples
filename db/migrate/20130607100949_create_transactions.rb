class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      
      t.string :token
      t.string :payer_id
      t.float :value
      t.string :transaction_id
      t.string :payment_state #Initiated, Authorized, Voided, Captured
      t.integer :user_id
      t.integer :product_id

      t.timestamps
    end
    add_index :transactions, :token
    add_index :transactions, :transaction_id, :unique => true
    add_index :transactions, :payer_id
    add_index :transactions, :product_id

  end
end
