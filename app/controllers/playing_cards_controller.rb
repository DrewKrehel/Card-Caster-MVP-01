class PlayingCardsController < ApplicationController
  before_action :set_card, only: [:flip, :move, :rotate]

  def flip
    @card.update!(face_up: params[:face_up])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  def move
    @card.update!(zone_name: params[:zone_name])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  def rotate
    card = PlayingCard.find(params[:id])

    card.orientation = case params[:direction]
      when "cw" then card.orientation_cw
      when "ccw" then card.orientation_ccw
      else card.orientation
      end

    card.save!

    redirect_back fallback_location: project_path(card.game_session.project)
  end

  # PATCH /game_sessions/:game_session_id/playing_cards/shuffle
  def shuffle
    game_session = GameSession.find(params[:game_session_id])
    zone_name = params[:zone_name]

    deck_service = DeckService.new(game_session, template_source: StandardDeckTemplate.new)
    deck_service.shuffle!(zone_name: zone_name)

    redirect_back fallback_location: game_session_path(game_session),
                  notice: "Shuffled #{zone_name} zone."
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end
end
