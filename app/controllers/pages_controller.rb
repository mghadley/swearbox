class PagesController < ApplicationController
  before_filter :ensure_logged_in, only: [:waiting_room, :score_board, :payment]

  def home
  end

  def waiting_room
    @body_class = 'waiting-room'
    redirect_to room_of_accounting_path if current_user.crawler_done
  end

  def login
    @body_class = 'login'
  end

  def score_board
    @body_class = 'waiting-room'
  end

  def payment
    @amount = "500"
  end
end
