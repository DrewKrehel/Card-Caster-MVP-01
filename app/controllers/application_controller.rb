class ApplicationController < ActionController::Base
  skip_forgery_protection

  def authorize_card_zone!(card)
    session_user = card.game_session.session_users.find_by(user: current_user)
    raise ActiveRecord::RecordNotFound unless session_user

    unless session_user.can_interact_with_zone?(card.zone_name)
      redirect_back fallback_location: game_session_path(card.game_session),
                    alert: "You are not allowed to interact with cards in this zone."
    end
  end
end
