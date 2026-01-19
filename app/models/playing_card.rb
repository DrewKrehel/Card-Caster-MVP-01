# == Schema Information
#
# Table name: playing_cards
#
#  id              :bigint           not null, primary key
#  back_image_url  :string
#  face_up         :boolean          default(FALSE)
#  image_url       :string
#  orientation     :integer          default(0)
#  position        :integer
#  rank            :string           not null
#  suit            :string           not null
#  zone_name       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_session_id :bigint           not null
#
# Indexes
#
#  idx_on_game_session_id_zone_name_position_682e3c4900  (game_session_id,zone_name,position)
#  index_playing_cards_on_game_session_id                (game_session_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_session_id => game_sessions.id)
#
class PlayingCard < ApplicationRecord
  belongs_to :game_session
end
