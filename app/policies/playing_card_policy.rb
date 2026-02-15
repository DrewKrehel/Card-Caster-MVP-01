# app/policies/playing_card_policy.rb
class PlayingCardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def initialize(user, record)
    @user = user
    @card = record
    @game_session = record.game_session
    @session_user = @game_session.session_users.find_by(user: @user)
  end

  def flip?
    can_interact_with_zone?
  end

  def move?
    can_interact_with_zone?
  end

  def rotate?
    can_interact_with_zone?
  end

  private

  def can_interact_with_zone?
    return false unless @session_user&.counts_as_player?

    @session_user.host? || 
      @card.zone_name == "Neutral" || 
      @card.zone_name == "Deck" || 
      @card.zone_name == @session_user.zone_name
  end
end
