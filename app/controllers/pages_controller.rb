class PagesController < ApplicationController
  before_filter :ensure_logged_in, only: :score_board
  def home
  end

  def score_board
  end
end
