# == Schema Information
#
# Table name: session_users
#
#  id              :bigint           not null, primary key
#  role            :integer          default(2), not null
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
  belongs_to :game_session
  belongs_to :user

  enum role: { host: 0, player: 1, observer: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :game_session_id, message: "already joined this session" }

  scope :hosts, -> { where(role: :host) }
  scope :players, -> { where(role: :player) }
  scope :observers, -> { where(role: :observer) }
  scope :for_game_session, ->(game_session_id) { where(game_session_id: game_session_id) }
end
