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
    new_zone = params[:zone_name]

    # If moving from deck, ALWAYS get the actual current top card
    if old_zone == "Deck"
      card_to_move = @card.game_session.playing_cards
                          .in_zone("Deck")
                          .ordered
                          .first

      # If deck is empty, show error
      unless card_to_move
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "zone-deck-cards",
              "<p class='text-muted fst-italic'>Deck is empty</p>"
            )
          end
          format.html do
            redirect_back fallback_location: game_session_path(@card.game_session),
                          alert: "The deck is empty."
          end
        end
        return
      end
    else
      card_to_move = @card
    end

    card_to_move.update!(zone_name: new_zone)

    respond_to do |format|
      format.turbo_stream do
        streams = []

        # If drawing from deck, update the entire deck zone
        if old_zone == "Deck"
          remaining_cards = @card.game_session.playing_cards.in_zone("Deck").ordered
          current_session_user = @card.game_session.session_users.find_by(user: current_user)
          can_interact = current_session_user&.can_interact_with_zone?("Deck")

          # Update entire deck zone with new top card or empty message
          streams << turbo_stream.update(
            "zone-deck-cards",
            partial: "game_sessions/zone_cards",
            locals: {
              zone: "Deck",
              zone_cards: remaining_cards,
              game_session: @card.game_session,
              can_interact: can_interact,
            },
          )
        else
          # Remove from old zone (non-deck)
          streams << turbo_stream.remove("card-#{card_to_move.id}")
        end

        # Update the NEW zone completely (replaces "No cards" message if present)
        new_zone_cards = @card.game_session.playing_cards.in_zone(new_zone).ordered
        current_session_user = @card.game_session.session_users.find_by(user: current_user)
        can_interact_new = current_session_user&.can_interact_with_zone?(new_zone)

        streams << turbo_stream.update(
          "zone-#{new_zone.parameterize}-cards",
          partial: "game_sessions/zone_cards",
          locals: {
            zone: new_zone,
            zone_cards: new_zone_cards,
            game_session: @card.game_session,
            can_interact: can_interact_new,
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

    authorize game_session

    unless policy(game_session).shuffle_zone?(zone_name)
      return redirect_back fallback_location: game_session_path(game_session),
                           alert: "You cannot shuffle this zone."
    end

    DeckService.new(game_session, template_source: StandardDeckTemplate.new)
               .shuffle!(zone_name: zone_name)

    zone_cards = game_session.playing_cards.in_zone(zone_name).ordered
    current_session_user = game_session.session_users.find_by(user: current_user)
    can_interact = current_session_user&.can_interact_with_zone?(zone_name)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "zone-#{zone_name.parameterize}-cards",
          partial: "game_sessions/zone_cards",
          locals: { # ← Explicitly passing locals
            zone: zone_name,
            zone_cards: zone_cards,
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
