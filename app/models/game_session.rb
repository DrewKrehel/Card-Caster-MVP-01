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
  belongs_to :project
  belongs_to :owner
end
