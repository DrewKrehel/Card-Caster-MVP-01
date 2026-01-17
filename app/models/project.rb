# == Schema Information
#
# Table name: projects
#
#  id           :bigint           not null, primary key
#  how_to_play  :text
#  image        :string
#  max_players  :integer          default(4), not null
#  private      :boolean          default(FALSE), not null
#  project_name :string
#  summary      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null
#
# Indexes
#
#  index_projects_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
class Project < ApplicationRecord
  belongs_to :creator, required: true, class_name: "User", foreign_key: "creator_id"

  has_many :owned_sessions, class_name: "Session", foreign_key: "project_id", dependent: :destroy

  validates :project_name, presence: true, uniqueness: { scope: :creator_id }, length: { maximum: 100 }
  validates :summary, length: { maximum: 500 }, allow_blank: true
  validates :image, url: true, allow_blank: true
  validates :creator, presence: true

  scope :public_projects, -> { where(private: false) }
  scope :by_creator, ->(user_id) { where(creator_id: user_id) }
end
