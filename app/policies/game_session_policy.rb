# app/policies/game_session_policy.rb
class GameSessionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def initialize(user, record)
    @user = user
    @game_session = record
    @session_user = @game_session.session_users.find_by(user: @user)
  end

  def show?
    return !@game_session.private? unless @user

    @game_session.users.exists?(@user.id) ||
      @game_session.owner == @user
  end

  def edit?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def join_as_player?
    @user.present? && !already_in_session?
  end

  def join_as_observer?
    return true unless @user # allow guests

    !already_in_session?
  end

  def toggle_role?
    @session_user.present? && !owner?
  end

  def leave?
    @session_user.present? && !owner?
  end

  def shuffle?
    @session_user.present?
  end

  def shuffle_zone?(zone_name)
    return false unless @session_user
    return true if @session_user.host?

    return false unless @session_user.player?

    # Players can shuffle:
    # - Their own zone
    # - Deck
    # - Neutral
    zone_name == @session_user.zone_name ||
      zone_name == "Deck" ||
      zone_name == "Neutral"
  end

  private

  def owner?
    @game_session.owner == @user
  end

  def already_in_session?
    @session_user.present?
  end
end
