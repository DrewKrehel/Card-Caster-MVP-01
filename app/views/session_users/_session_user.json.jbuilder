json.extract! session_user, :id, :game_session_id, :user_id, :role, :created_at, :updated_at
json.url session_user_url(session_user, format: :json)
