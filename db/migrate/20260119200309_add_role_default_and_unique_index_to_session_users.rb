class AddRoleDefaultAndUniqueIndexToSessionUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :session_users, :role, 2
    change_column_null :session_users, :role, false
  end
end
