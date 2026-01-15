class CreatePlayingCards < ActiveRecord::Migration[8.0]
  def change
    create_table :playing_cards do |t|
      t.references :session, null: false, foreign_key: true
      t.string :suit, null: false
      t.string :rank, null: false
      t.string :zone_name, null: false
      t.boolean :face_up, default: false
      t.integer :orientation, default: 0
      t.integer :position
      t.string :image_url
      t.string :back_image_url

      t.timestamps
    end

    add_index :playing_cards, [:session_id, :zone_name, :position]
  end
end
