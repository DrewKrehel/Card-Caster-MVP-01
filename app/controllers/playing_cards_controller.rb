class PlayingCardsController < ApplicationController
  before_action :set_card, only: [:flip, :move, :rotate]
  before_action :authorize_card_zone!, only: [:flip, :move, :rotate]

  # PATCH /playing_cards/:id/flip
  def flip
    @card.update!(face_up: params[:face_up])
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
  end

  # PATCH /playing_cards/:id/move
  def move
    card_to_move =
      if @card.zone_name == "Deck"
        @card.game_session.playing_cards.in_zone("Deck").ordered.first
      else
        @card
      end

    card_to_move.update!(zone_name: params[:zone_name])

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
  end

  # PATCH /playing_cards/:id/rotate
  def rotate
    @card.orientation = case params[:direction]
                        when "cw" then @card.orientation_cw
                        when "ccw" then @card.orientation_ccw
                        else @card.orientation
                        end
    @card.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end

  def authorize_card_zone!
    authorize_card_zone!(@card) # assumes your existing Pundit / zone auth
  end
end
