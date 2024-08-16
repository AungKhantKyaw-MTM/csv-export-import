json.extract! post, :id, :title, :body, :author, :likes, :comments, :created_at, :updated_at
json.url post_url(post, format: :json)
