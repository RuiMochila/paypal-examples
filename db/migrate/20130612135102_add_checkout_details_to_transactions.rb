class AddCheckoutDetailsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :checkout_details, :string
  end
end
