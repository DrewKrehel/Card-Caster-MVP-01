class ChangeUsersEmailAndUsernameToCitext < ActiveRecord::Migration[8.0]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    change_column :users, :email, :citext
    change_column :users, :username, :citext
  end
end
