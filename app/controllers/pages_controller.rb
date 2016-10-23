class PagesController < ApplicationController
  before_filter :ensure_logged_in, only: [:score_board, :payment]

  def home
  end

  def waiting_room
    redirect_to room_of_accounting_path if current_user.crawler_done
  end

  def login
  end

  def score_board
  end

  def payment
    @amount = "500"
  end
end
