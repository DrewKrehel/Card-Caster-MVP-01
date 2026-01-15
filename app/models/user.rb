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
#  index_users_on_lower_username        (lower((username)::text)) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :projects, class_name: "Project", foreign_key: "creator_id", dependent: :destroy
  has_many :active_sessions, class_name: "SessionUser", foreign_key: "user_id", dependent: :nullify
  has_many :sessions, class_name: "Session", foreign_key: "owner_id", dependent: :destroy
  has_many :session_users, dependent: :destroy
  has_many :sessions, through: :session_users
end
