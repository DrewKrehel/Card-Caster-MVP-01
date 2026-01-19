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

  validates :session_name, presence: true, uniqueness: { scope: :project_id }, length: { maximum: 100 }
  validates :project, presence: true
  validates :owner, presence: true

  scope :owned_by, ->(user_id) { where(owner_id: user_id) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }

  after_create :populate_standard_deck

  private

  def populate_standard_deck
    DeckService.new(self, template_source: StandardDeckTemplate.new).build_deck
    DeckService.new(self, template_source: StandardDeckTemplate.new).shuffle!
  end
end
