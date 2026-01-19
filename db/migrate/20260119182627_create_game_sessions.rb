class CreateGameSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :game_sessions do |t|
      t.references :project, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.boolean :private

      t.timestamps
    end
  end
end


