class CsvImportService
  require 'csv'

  def call(file_content)
    options = { headers: true, col_sep: ',' }

    create_posts = []
    update_posts = []
    delete_posts = []

    CSV.parse(file_content, **options) do |row|
      action = row['action'].downcase
      post_id = row['id']

      case action
      when 'create'
        post_attributes = extract_post_attributes(row)
        create_posts << post_attributes if post_attributes
      when 'update'
        post_attributes = extract_post_attributes(row)
        update_posts << { id: post_id, attributes: post_attributes } if post_attributes
      when 'delete'
        delete_posts << post_id
      else
        Rails.logger.error "Unknown action '#{action}' for row #{row.to_hash}"
      end
    end

    import_all(create_posts) unless create_posts.empty?
    update_all(update_posts) unless update_posts.empty?
    delete_ids(delete_posts) unless delete_posts.empty?
  end

  private

  def import_all(records)
    Post.import(records)
  end

  def update_all(records)
    records.each do |record|
      post = Post.find_by(id: record[:id])
      if post
        post.update!(record[:attributes])
      else
        Rails.logger.error "Post with id '#{record[:id]}' not found for update action"
      end
    end
  end

  def delete_ids(ids)
    Post.where(id: ids).destroy_all
  end

  def extract_post_attributes(row)
    title = row['title']
    body = row['body']
    author = row['author']

    if title.present? && body.present? && author.present?
      {
        title: title,
        body: body,
        author: author,
        likes: row['likes'],
        comments: row['comments']
      }
    else
      Rails.logger.error "Missing required fields for row #{row.to_hash}"
      nil
    end
  end
end
