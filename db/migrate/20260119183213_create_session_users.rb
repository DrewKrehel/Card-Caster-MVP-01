class CreateSessionUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :session_users do |t|
      t.references :game_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end

    add_index :session_users, [:game_session_id, :user_id], unique: true
  end
end


