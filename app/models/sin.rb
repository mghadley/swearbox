class Sin < ApplicationRecord
  belongs_to :user
  belongs_to :swearword

  def self.with_totals(user)
  	sins = []
  	where(user_id: user.id).each do |sin|
  		swearword = Swearword.find_by(id: sin.swearword_id)
  		ppw = swearword.price
  		total = sin.count * ppw
  		sins << { word: swearword.word.titleize, count: sin.count, ppw: ppw, total: total }
  	end
  	return sins
  end
end
