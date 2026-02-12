class PlayingCardsController < ApplicationController
  before_action :set_card, only: [:flip, :move, :rotate]
  before_action :authorize_zone_action!, only: [:flip, :move, :rotate]

  def rotate
    @card.rotate!(:cw)
    render_card
  end

  def flip
    @card.update!(face_up: params[:face_up])
    render_card
  end

  def move
    @card.update!(zone_name: params[:zone_name])
    render_zone
  end

  def shuffle
    game_session = GameSession.find(params[:game_session_id])
    zone_name = params[:zone_name]

    DeckService.new(game_session, template_source: StandardDeckTemplate.new)
               .shuffle!(zone_name: zone_name)

    @game_session = game_session
    @zone_name = zone_name
    @session_user = game_session.session_users.find_by(user: current_user)

    render "playing_cards/zone_grid", formats: :turbo_stream
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end

  def render_card
    render turbo_stream: turbo_stream.replace(
      dom_id(@card),
      partial: "playing_cards/playing_card",
      locals: {
        card: @card,
        current_zone: @card.zone_name,
        can_interact: true
      }
    )
  end

  def render_zone
    render turbo_stream: turbo_stream.replace(
      dom_id(@card.game_session, @card.zone_name.parameterize),
      partial: "playing_cards/zone_grid",
      locals: {
        game_session: @card.game_session,
        zone_name: @card.zone_name,
        session_user: @card.game_session.session_users.find_by(user: current_user)
      }
    )
  end
end
