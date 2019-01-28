json.extract! user, :id, :title, :content, :category, :user_id, :created_at, :updated_at
json.url user_url(user, format: :json)
