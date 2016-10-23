class ChargesController < ApplicationController
	def create
		@amount = 500

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
			redirect_to hall_of_shame_path
		end
	rescue Stripe::CardError => e
		flash[:error] = e.message
		binding.pry
		redirect_to pages_payment_path
	end
end
