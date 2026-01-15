json.extract! playing_card, :id, :session_id, :suit, :rank, :zone_name, :face_up, :orientation, :position, :image_url, :back_image_url, :created_at, :updated_at
json.url playing_card_url(playing_card, format: :json)
