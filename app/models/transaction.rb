# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  token            :string(255)
#  payer_id         :string(255)
#  value            :float
#  transaction_id   :string(255)
#  payment_state    :string(255)
#  product_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_email       :string(255)
#  user_name        :string(255)
#  checkout_details :string(255)
#  color            :string(255)
#  size             :string(255)
#

class Transaction < ActiveRecord::Base
	
  attr_accessible :token, :payer_id, :value, :transaction_id, :payment_state, :user_id, :product_id

  validates :payment_state,
    :inclusion  => { :in => [ 'Initiated', 'Authorized', 'Voided', 'Captured' ] }
   
end
