# app/services/standard_deck_template.rb
class StandardDeckTemplate
  SUITS = %w[hearts diamonds clubs spades].freeze
  RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

  Template = Struct.new(:suit, :rank, :image_url, :back_image_url)

  def templates
    SUITS.flat_map do |suit|
      RANKS.map do |rank|
        Template.new(
          suit,
          rank,
          image(suit, rank),
          back_image
        )
      end
    end
  end

  private

  def image(suit, rank)
    "standard_deck_cards/#{rank}_of_#{suit}.png"
  end

  def back_image
    "standard_deck_cards/card_back.png"    
  end
end
