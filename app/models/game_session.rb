# == Schema Information
#
# Table name: game_sessions
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
#  index_game_sessions_on_owner_id    (owner_id)
#  index_game_sessions_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#  fk_rails_...  (project_id => projects.id)
#
class GameSession < ApplicationRecord
  belongs_to :project, required: true
  belongs_to :owner, required: true, class_name: "User", foreign_key: "owner_id"

  has_many :session_users, dependent: :destroy
  has_many :users, through: :session_users
  has_many :playing_cards, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :project_id }, length: { maximum: 100 }
  validates :project, presence: true
  validates :owner, presence: true

  scope :owned_by, ->(user_id) { where(owner_id: user_id) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }

  after_create :populate_standard_deck

  MAX_PLAYER_ZONES = ["Player 1", "Player 2", "Player 3", "Player 4"]

  def next_available_player_zone
    taken = session_users.where.not(zone_name: nil).pluck(:zone_name)
    MAX_PLAYER_ZONES.find { |zone| !taken.include?(zone) }
  end

  # private

  def populate_standard_deck
    deck_service = DeckService.new(self, template_source: StandardDeckTemplate.new)
    deck_service.build_deck(zone_name: "Deck")
    deck_service.shuffle!(zone_name: "Deck")
  end

  def active_player_count
    session_users.player_like.count
  end

  def available_player_slots
    project.max_players - active_player_count
  end

  def player_slots_remaining?
    available_player_slots.positive?
  end

  def user_for_zone(zone)
    session_users.find_by(zone_name: zone)&.user
  end
end
