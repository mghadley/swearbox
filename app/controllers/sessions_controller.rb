class SessionsController < ApplicationController
skip_before_filter :verify_authenticity_token, :only => :create

  def create
    user = User.find_or_create_by(:provider => auth_hash[:provider], :uid => auth_hash[:uid], :github_username => auth_hash[:nickname]) do |user|
      user.name = auth_hash[:info][:name]
      user.github_username = auth_hash[:info][:nickname]
    end

    session[:user_id] = user.id
    redirect_to :pages_score_board, notice: "Signed in successfully!"
  end

  def destroy
    reset_session
    redirect_to :root, notice: "Signed out"
  end

  private
  def auth_hash
    request.env["omniauth.auth"]
  end
end
