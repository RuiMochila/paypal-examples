class ChangesToTransaction < ActiveRecord::Migration
  def change
  	remove_column :transactions, :user_id
  	add_column :transactions, :user_email, :string
  	add_column :transactions, :user_name, :string
  end
end
