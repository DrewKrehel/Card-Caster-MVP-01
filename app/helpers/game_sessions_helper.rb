# app/helpers/game_sessions_helper.rb
module GameSessionsHelper
  def can_interact_with_card?(card, game_session)
    return false unless current_user

    session_user = game_session.session_users.find_by(user: current_user)
    return false unless session_user

    session_user.can_interact_with_zone?(card.zone_name)
  end
end
