class PlayingCardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:flip, :move, :rotate]

  # PATCH /playing_cards/:id/flip
  def flip
    authorize @card
    @card.update!(face_up: params[:face_up])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  # PATCH /playing_cards/:id/move
  def move
    authorize @card
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
    authorize @card
    # Rails.logger.info "Rotating card #{params[:id]} direction=#{params[:direction]}"
    @card.orientation = case params[:direction]
      when "cw" then @card.orientation_cw
      when "ccw" then @card.orientation_ccw
      else @card.orientation
      end
    @card.save!
    # Rails.logger.info "New orientation: #{@card.orientation}"
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  # PATCH /game_sessions/:game_session_id/playing_cards/shuffle
  def shuffle
    game_session = GameSession.find(params[:game_session_id])
    zone_name = params[:zone_name]

    authorize game_session, :shuffle_zone?

    unless policy(game_session).shuffle_zone?(zone_name)
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
