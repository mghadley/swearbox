class SinsController < ApplicationController
  def index
  	@sins = Sin.with_totals(current_user)
  	@grand_total = (@sins.map{ |s| s[:total] }).reduce(:+)
  end
end
