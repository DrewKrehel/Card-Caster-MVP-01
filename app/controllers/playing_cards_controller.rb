class PlayingCardsController < ApplicationController
  before_action :set_card

  def flip
    @card.update!(face_up: params[:face_up])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  def move
    @card.update!(zone_name: params[:zone_name])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  def rotate
    @card.update!(orientation: params[:orientation])
    redirect_back fallback_location: game_session_path(@card.game_session)
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end
end
