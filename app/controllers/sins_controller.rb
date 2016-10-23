class SinsController < ApplicationController
  def index
    redirect_to waiting_room_path unless current_user.crawler_done
  	@sins = Sin.with_totals(current_user)
  	@grand_total = (@sins.map{ |s| s[:total] }).reduce(:+)
  end
end
