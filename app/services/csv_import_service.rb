class CsvImportService
    require 'csv'
  
    def call(file)
      opened_file = File.open(file)
      options = { headers: true, col_sep: ',' }

      create_posts = []
      update_posts = []
      delete_posts = []

      CSV.foreach(opened_file, **options) do |row|
        action = row['action'].downcase
        post_id = row['id']

        case action
        when 'create'
          create_posts << extract_post_attributes(row)
        when 'update'
          update_posts << { id: post_id, attributes: extract_post_attributes(row) }
        when 'delete'
          delete_posts << post_id
        else
          Rails.logger.error "Unknown action '#{action}' for row #{row.to_hash}"
        end
      end

      import_all(create_posts)
      update_all(update_posts)
      delete_ids(delete_posts)
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
      {
        title: row['title'],
        body: row['body'],
        author: row['author'],
        likes: row['likes'],
        comments: row['comments']
      }
    end
  end