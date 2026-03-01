class UsersController < ApplicationController
  before_action :set_user, only: :show
  before_action :set_breadcrumbs, only: :show

  def index
    @users = User.order(:username)
  end

  def show
    @user = User.find_by!(username: params.fetch(:username))

    @owned_projects = @user.projects.includes(:game_sessions)

    @active_game_sessions =
      GameSession
        .joins(:session_users)
        .where(session_users: { user_id: @user.id })
        .includes(:owner, :project, :session_users)
        .distinct
  end

  private

  def set_user
    @user = User.find_by!(username: params.fetch(:username))
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { name: "Users", url: users_path },
      { name: "@#{@user.username}", url: nil }
    ]
  end
end
