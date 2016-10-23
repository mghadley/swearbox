class SinsController < ApplicationController
  def index
    redirect_to waiting_room_path unless current_user.crawler_done
  	@sins = Sin.with_totals(current_user)
    redirect_to no_sins_path and return unless @sins.any?
  	@grand_total = (@sins.map{ |s| s[:total] }).reduce(:+)
    @total_charge = @grand_total > 50 ? @grand_total : 50
    @paid = current_user.paid
  end

  def no_sins
    @sins = current_user.sins
    redirect_to room_of_accounting_path if @sins.any?
  end
end
