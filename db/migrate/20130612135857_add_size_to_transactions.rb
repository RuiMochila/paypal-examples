class AddSizeToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :size, :string
  end
end
