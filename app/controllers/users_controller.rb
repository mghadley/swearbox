class UsersController < ApplicationController
  def index
  end

  def show
  end

  def check_crawler
    render json: current_user.crawler_done
  end

  def hall_of_shame
  	@users = User.top_ten
  end
end
