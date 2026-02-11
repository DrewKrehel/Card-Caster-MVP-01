# == Schema Information
#
# Table name: playing_cards
#
#  id              :bigint           not null, primary key
#  back_image_url  :string
#  face_up         :boolean          default(FALSE)
#  image_url       :string
#  orientation     :integer          default("normal")
#  position        :integer
#  rank            :string           not null
#  suit            :string           not null
#  zone_name       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_session_id :bigint           not null
#
# Indexes
#
#  idx_on_game_session_id_zone_name_position_682e3c4900  (game_session_id,zone_name,position)
#  index_playing_cards_on_game_session_id                (game_session_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_session_id => game_sessions.id)
#
class PlayingCard < ApplicationRecord
  ZONES = ["Deck", "Neutral", "Player 1", "Player 2", "Player 3", "Player 4"].freeze

  belongs_to :game_session

  attribute :face_up, :boolean, default: false
  attribute :orientation, :integer, default: 0

  enum :orientation, { normal: 0, rotated90: 1, rotated180: 2, rotated270: 3 }

  before_validation :ensure_valid_orientation

  validates :suit, presence: true, inclusion: { in: %w[hearts diamonds clubs spades] }
  validates :rank, presence: true, inclusion: { in: %w[A 2 3 4 5 6 7 8 9 10 J Q K] }
  validates :zone_name, presence: true, inclusion: { in: ZONES }
  validates :game_session, presence: true


  scope :in_zone, ->(zone_name) { where(zone_name: zone_name) }
  scope :face_up, -> { where(face_up: true) }
  scope :face_down, -> { where(face_up: false) }
  scope :ordered, -> { order(:position) }
  scope :with_suit, ->(suit) { where(suit: suit) }
  scope :with_rank, ->(rank) { where(rank: rank) }

  def card_name
    "#{rank} of #{suit.capitalize}"
  end

  def display_image
    face_up? ? image_url : back_image_url
  end

  def orientation_degrees
    self.class.orientations[orientation] * 90
  end

  def orientation_cw
    self.class.orientations.keys[
      (self.class.orientations[orientation] + 1) % 4
    ]
  end

  def orientation_ccw
    self.class.orientations.keys[
      (self.class.orientations[orientation] - 1) % 4
    ]
  end

  private

  # Ensures orientation always maps to a valid enum value.
  def ensure_valid_orientation
    return if orientation.present? && self.class.orientations.value?(orientation)

    self.orientation = "normal"
  end
end
