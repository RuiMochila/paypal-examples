class ProductsController < ApplicationController


	def index
		@transactions = Transaction.all
	end

	def show
		
	end
	
end