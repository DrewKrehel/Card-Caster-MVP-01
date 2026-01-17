# == Schema Information
#
# Table name: session_users
#
#  id         :bigint           not null, primary key
#  role       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  session_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_session_users_on_session_id              (session_id)
#  index_session_users_on_session_id_and_user_id  (session_id,user_id) UNIQUE
#  index_session_users_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (user_id => users.id)
#
class SessionUser < ApplicationRecord
  belongs_to :session
  belongs_to :user

  #enum role: { host: 0, player: 1, observer: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :session_id, message: "already joined this session" }
end
