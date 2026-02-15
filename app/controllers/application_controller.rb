class ApplicationController < ActionController::Base
  skip_forgery_protection

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:username, :avatar_image, :bio],
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:username, :avatar_image, :bio],
    )
  end

  # Ensures the current user is allowed to interact with a card based on its zone.
  def authorize_card_zone!(card)
    session_user = card.game_session.session_users.find_by(user: current_user)
    raise ActiveRecord::RecordNotFound unless session_user

    unless session_user.can_interact_with_zone?(card.zone_name)
      redirect_back fallback_location: game_session_path(card.game_session),
                    alert: "You are not allowed to interact with cards in this zone."
    end
  end
end
