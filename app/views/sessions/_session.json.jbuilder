json.extract! session, :id, :project_id, :owner_id, :name, :private, :created_at, :updated_at
json.url session_url(session, format: :json)
