# == Schema Information
#
# Table name: sessions
#
#  id         :bigint           not null, primary key
#  name       :string
#  private    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint           not null
#  project_id :bigint           not null
#
# Indexes
#
#  index_sessions_on_owner_id    (owner_id)
#  index_sessions_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#  fk_rails_...  (project_id => projects.id)
#
class Session < ApplicationRecord
  belongs_to :project, required: true
  belongs_to :owner, required: true, class_name: "User", foreign_key: "owner_id"

  has_many :session_users, dependent: :destroy
  has_many :users, through: :session_users
  has_many :playing_cards, dependent: :destroy

  after_create :populate_deck

  private

  def populate_deck
    suits = %w[hearts diamonds clubs spades]
    ranks = %w[A 2 3 4 5 6 7 8 9 10 J Q K]

    suits.each do |suit|
      ranks.each do |rank|
        playing_cards.create!(
          suit: suit,
          rank: rank,
          zone_name: "Neutral",
          face_up: false,
          orientation: 0,
          position: nil,
          image_url: nil,
          back_image_url: nil
        )
      end
    end
  end
end
