json.extract! project, :id, :owner_id, :project_name, :summary, :how_to_play, :max_players, :image, :private, :created_at, :updated_at
json.url project_url(project, format: :json)
