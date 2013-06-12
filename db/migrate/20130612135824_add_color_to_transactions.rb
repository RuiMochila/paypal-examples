class AddColorToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :color, :string
  end
end
