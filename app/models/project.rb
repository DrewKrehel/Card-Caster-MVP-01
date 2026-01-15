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
#  owner_id     :bigint           not null
#
# Indexes
#
#  index_projects_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Project < ApplicationRecord
  belongs_to :owner, required: true, class_name: "User", foreign_key: "owner_id"

  has_many  :sessions, class_name: "Session", foreign_key: "project_id", dependent: :destroy
end
