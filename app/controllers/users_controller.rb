class UsersController < ApplicationController
  def index
  end

  def hall_of_shame
  	@users = User.top_ten
  end
end
