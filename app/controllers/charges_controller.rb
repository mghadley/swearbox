class ChargesController < ApplicationController
	def create
		@amount = current_user.total_owed > 50 ? current_user.total_owed : 50

		customer = Stripe::Customer.create(
			email: params[:stripeEmail],
			source: params[:stripeToken]
		)

		charge = Stripe::Charge.create(
			customer: customer.id,
			amount: @amount,
			description: "Donation to Khan Academy from #{current_user.name}",
			currency: 'usd'
		)

		unless charge.failure_code
			current_user.update(paid: true)
			redirect_to room_of_accounting_path
		end
	rescue Stripe::CardError => e
		flash[:error] = e.message
		binding.pry
		redirect_to pages_payment_path
	end
end
