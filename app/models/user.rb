# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_image           :string(255)
#  bio                    :text
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  private                :boolean          default(FALSE), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :citext           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  mount_uploader :avatar_image, ImageUploader

  DEFAULT_AVATAR = "default-avatar.jpg"

  has_many :projects, class_name: "Project", foreign_key: "creator_id", dependent: :destroy
  has_many :owned_sessions, class_name: "GameSession", foreign_key: "owner_id", dependent: :destroy
  has_many :session_users, dependent: :destroy
  has_many :active_sessions, through: :session_users

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :bio, length: { maximum: 500 }, allow_blank: true

  scope :public_users, -> { where(private: false) }
  scope :with_username, ->(name) { where('LOWER(username) = ?', name.downcase) }

  def profile_image
    avatar_image? ? avatar_image_url : DEFAULT_AVATAR
  end
end
