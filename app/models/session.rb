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

  validates :session_name, presence: true, uniqueness: { scope: :project_id }, length: { maximum: 100 }
  validates :project, presence: true
  validates :owner, presence: true
end
