class UsersController < ApplicationController
  def index
   @users = User.order(:username)
  end

  def show
    @user = User.find_by!(username: params.fetch(:username))
  end
end
