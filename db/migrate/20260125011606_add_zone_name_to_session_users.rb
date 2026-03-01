class AddZoneNameToSessionUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :session_users, :zone_name, :string
  end
end
