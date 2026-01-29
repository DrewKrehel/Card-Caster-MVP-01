class UsersController < ApplicationController
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
end
