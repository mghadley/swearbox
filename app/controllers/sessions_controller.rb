class SessionsController < ApplicationController
skip_before_filter :verify_authenticity_token, :only => :create

  def create
    user = User.find_or_create_by(:provider => auth_hash[:provider], :uid => auth_hash[:uid]) do |user|
      user.name = auth_hash[:info][:name]
      user.github_username = auth_hash[:info][:nickname]
    end

    session[:user_id] = user.id
    redirect_to waiting_room_path, notice: "Signed in successfully!"
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out"
  end

  private
  def auth_hash
    request.env["omniauth.auth"]
  end
end
