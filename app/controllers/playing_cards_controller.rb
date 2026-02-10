class PlayingCardsController < ApplicationController
  before_action :set_card, only: [:flip, :move, :rotate]
  before_action :authorize_zone_action!, only: [:flip, :move, :rotate]

  # PATCH /playing_cards/:id/flip
  def flip
    @card.update!(face_up: params[:face_up])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  # PATCH /playing_cards/:id/move
  def move
    if @card.zone_name == "Deck"
      card_to_move =
        @card.game_session.playing_cards
             .in_zone("Deck")
             .ordered
             .first
    else
      card_to_move = @card
    end

    card_to_move.update!(zone_name: params[:zone_name])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  # PATCH /playing_cards/:id/rotate
  def rotate
    @card.orientation = case params[:direction]
      when "cw" then @card.orientation_cw
      when "ccw" then @card.orientation_ccw
      else @card.orientation
      end

    @card.save!
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  # PATCH /game_sessions/:game_session_id/playing_cards/shuffle
  def shuffle
    game_session = GameSession.find(params[:game_session_id])
    zone_name = params[:zone_name]

    session_user = game_session.session_users.find_by(user: current_user)

    unless session_user&.host? ||
           (session_user.player? && session_user.zone_name == zone_name)
      return redirect_back fallback_location: game_session_path(game_session),
                           alert: "You cannot shuffle this zone."
    end

    DeckService.new(game_session, template_source: StandardDeckTemplate.new)
               .shuffle!(zone_name: zone_name)

    redirect_back fallback_location: game_session_path(game_session),
                  notice: "Shuffled #{zone_name}."
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end

  def authorize_zone_action!
    authorize_card_zone!(@card)
  end
end
