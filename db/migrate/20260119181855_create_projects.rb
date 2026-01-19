class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.text :summary
      t.text :how_to_play
      t.integer :max_players, null: false, default: 4
      t.string :image
      t.boolean :private, null: false, default: false

      t.timestamps
    end
  end
end


