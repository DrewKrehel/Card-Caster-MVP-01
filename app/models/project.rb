# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  how_to_play :text
#  image       :string
#  max_players :integer          default(4), not null
#  name        :string
#  private     :boolean          default(FALSE), not null
#  summary     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  creator_id  :bigint           not null
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
  belongs_to :creator
end
