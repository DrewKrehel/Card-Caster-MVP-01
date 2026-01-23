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
          default_front_image(suit, rank),
          default_back_image
        )
      end
    end
  end

  private

  def default_front_image(suit, rank)
    "/images/cards/#{rank}_of_#{suit}.png"
  end

  def default_back_image
    "/images/cards/card_back.png"
  end
end
