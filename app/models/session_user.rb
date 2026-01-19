# == Schema Information
#
# Table name: session_users
#
#  id              :bigint           not null, primary key
#  role            :integer
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
end
