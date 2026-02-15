# == Schema Information
#
# Table name: session_users
#
#  id              :bigint           not null, primary key
#  role            :integer          default("observer"), not null
#  zone_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_session_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_session_users_on_game_session_id              (game_session_id)
#  index_session_users_on_game_session_id_and_user_id  (game_session_id,user_id) UNIQUE
#  index_session_users_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_session_id => game_sessions.id)
#  fk_rails_...  (user_id => users.id)
#
class SessionUser < ApplicationRecord
  belongs_to :active_session, class_name: "GameSession", foreign_key: "game_session_id"
  belongs_to :user

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :game_session_id, message: "already joined this session" }
  validate :player_like_users_must_have_zone

  enum :role, { host: 0, player: 1, observer: 2 }

  scope :hosts, -> { where(role: :host) }
  scope :players, -> { where(role: :player) }
  scope :observers, -> { where(role: :observer) }
  scope :for_game_session, ->(game_session_id) { where(game_session_id: game_session_id) }
  scope :player_like, -> { where(role: [:host, :player]) }

  def can_interact_with_zone?(zone_name)
    return false unless counts_as_player?

    host? || zone_name == "Neutral" || zone_name == "Deck" || zone_name == self.zone_name
  end

  def counts_as_player?
    host? || player?
  end
  
  def player_like_users_must_have_zone
    if counts_as_player? && zone_name.blank?
      errors.add(:zone_name, "must be assigned for players")
    end
  end
end
