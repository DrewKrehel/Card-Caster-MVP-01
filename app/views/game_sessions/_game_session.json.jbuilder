json.extract! game_session, :id, :project_id, :owner_id, :name, :private, :created_at, :updated_at
json.url game_session_url(game_session, format: :json)
