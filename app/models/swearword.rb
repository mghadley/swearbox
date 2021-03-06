class Swearword < ApplicationRecord
	has_many :sins
	has_many :users, through: :sins

	validates_uniqueness_of :word
	validates_presence_of :word, :tier

	def price
		if tier == 1
			return 5
		elsif tier == 2
			return 10
		else
			return 25
		end
	end
end
