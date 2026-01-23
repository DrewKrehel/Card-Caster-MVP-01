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
    card = PlayingCard.find(params[:id])

    card.orientation = case params[:direction]
      when "cw" then card.orientation_cw
      when "ccw" then card.orientation_ccw
      else card.orientation
      end

    card.save!

    redirect_back fallback_location: project_path(card.game_session.project)
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end
end
