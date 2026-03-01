# app/services/deck_service.rb
class DeckService
  def initialize(session, template_source:)
    @session = session
    @template_source = template_source
  end

  def build_deck(zone_name: "Neutral")
    @template_source.templates.each do |template|
      create_playing_card(template, zone_name)
    end
  end

  def shuffle!(zone_name: "Neutral")
    cards = @session.playing_cards
                    .where(zone_name: zone_name)
                    .order(Arel.sql("RANDOM()"))

    cards.each_with_index do |card, index|
      card.update!(position: index)
    end
  end

  private

  def create_playing_card(template, zone_name)
    @session.playing_cards.create!(
      suit: template.suit,
      rank: template.rank,
      image_url: template.image_url,
      back_image_url: template.back_image_url,
      zone_name: zone_name,
      face_up: false,
      orientation: 0,
      position: nil
    )
  end
end
