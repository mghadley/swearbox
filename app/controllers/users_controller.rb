class UsersController < ApplicationController
  def index
  end

  def show
  end

  def recrawl
    current_user.sins.delete_all
    current_user.update(crawler_started: true, crawler_done: false)
    CrawlerWorker.perform_async(current_user.id)
    redirect_to waiting_room_path
  end

  def check_crawler
    render json: current_user.crawler_done
  end

  def hall_of_shame
  	@users = User.top_ten
  end
end
