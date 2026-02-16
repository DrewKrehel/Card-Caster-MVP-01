class PlayingCardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: [:flip, :move, :rotate]

  # PATCH /playing_cards/:id/flip
  def flip
    authorize @card
    @card.update!(face_up: params[:face_up])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "card-#{@card.id}",
          partial: "playing_cards/playing_card",
          locals: { card: @card, current_zone: @card.zone_name, can_interact: can_interact_with_card?(@card) },
        )
      end
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
  end

  # PATCH /playing_cards/:id/move
  def move
    authorize @card

    old_zone = @card.zone_name

    if @card.zone_name == "Deck"
      card_to_move = @card.game_session.playing_cards.in_zone("Deck").ordered.first
    else
      card_to_move = @card
    end

    new_zone = params[:zone_name]
    card_to_move.update!(zone_name: new_zone)

    respond_to do |format|
      format.turbo_stream do
        streams = []

        # If drawing from deck, update the deck display
        if old_zone == "Deck"
          remaining_cards = @card.game_session.playing_cards.in_zone("Deck").ordered

          if remaining_cards.any?
            # Update deck with new top card
            streams << turbo_stream.replace(
              "deck-#{@card.game_session.id}",
              partial: "playing_cards/deck",
              locals: {
                game_session: @card.game_session,
                top_card: remaining_cards.first,
              },
            )
          else
            # Deck is empty, show empty message
            streams << turbo_stream.replace(
              "deck-#{@card.game_session.id}",
              "<p class='text-muted fst-italic'>Deck is empty</p>"
            )
          end
        else
          # Remove from old zone (non-deck)
          streams << turbo_stream.remove("card-#{card_to_move.id}")
        end

        # Add to new zone
        streams << turbo_stream.append(
          "zone-#{new_zone.parameterize}-cards",
          partial: "playing_cards/playing_card",
          locals: {
            card: card_to_move,
            current_zone: new_zone,
            can_interact: can_interact_with_card?(card_to_move),
          },
        )

        render turbo_stream: streams
      end
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
  end

  # PATCH /playing_cards/:id/rotate
  def rotate
    authorize @card

    @card.orientation = case params[:direction]
      when "cw" then @card.orientation_cw
      when "ccw" then @card.orientation_ccw
      else @card.orientation
      end

    @card.save!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "card-#{@card.id}",
          partial: "playing_cards/playing_card",
          locals: { card: @card, current_zone: @card.zone_name, can_interact: can_interact_with_card?(@card) },
        )
      end
      format.html { redirect_back fallback_location: game_session_path(@card.game_session) }
    end
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

    respond_to do |format|
      format.turbo_stream do
        # Reload all cards in the shuffled zone
        cards = game_session.playing_cards.in_zone(zone_name).ordered
        current_session_user = game_session.session_users.find_by(user: current_user)
        can_interact = current_session_user&.can_interact_with_zone?(zone_name)

        render turbo_stream: turbo_stream.replace(
          "zone-#{zone_name.parameterize}-cards",
          partial: "game_sessions/zone_cards",
          locals: {
            zone: zone_name,
            zone_cards: cards,
            game_session: game_session,
            can_interact: can_interact,
          },
        )
      end
      format.html do
        redirect_back fallback_location: game_session_path(game_session),
                      notice: "Shuffled #{zone_name}."
      end
    end
  end

  private

  def set_card
    @card = PlayingCard.find(params[:id])
  end

  def can_interact_with_card?(card)
    session_user = card.game_session.session_users.find_by(user: current_user)
    session_user&.can_interact_with_zone?(card.zone_name)
  end

  def authorize_zone_action!
    authorize_card_zone!(@card)
  end
end
