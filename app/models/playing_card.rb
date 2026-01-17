# == Schema Information
#
# Table name: playing_cards
#
#  id             :bigint           not null, primary key
#  back_image_url :string
#  face_up        :boolean          default(FALSE)
#  image_url      :string
#  orientation    :integer          default(0)
#  position       :integer
#  rank           :string           not null
#  suit           :string           not null
#  zone_name      :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  session_id     :bigint           not null
#
# Indexes
#
#  index_playing_cards_on_session_id                             (session_id)
#  index_playing_cards_on_session_id_and_zone_name_and_position  (session_id,zone_name,position)
#
# Foreign Keys
#
#  fk_rails_...  (session_id => sessions.id)
#
class PlayingCard < ApplicationRecord
  belongs_to :session

  enum orientation: { normal: 0, rotated90: 1, rotated180: 2, rotated270: 3 }

  validates :suit, presence: true, inclusion: { in: %w[hearts diamonds clubs spades] }
  validates :rank, presence: true, inclusion: { in: %w[A 2 3 4 5 6 7 8 9 10 J Q K] }
  validates :zone_name, presence: true, inclusion: { in: ["Neutral", "Player 1", "Player 2", "Player 3", "Player 4"] }
  validates :session, presence: true

  def card_name
    "#{rank} of #{suit.capitalize}"
  end

  def display_image
    face_up? ? image_url : back_image_url
  end
end
