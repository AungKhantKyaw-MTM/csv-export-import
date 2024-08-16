class CsvImportService
    require 'csv'
  
    def call(file)
      opened_file = File.open(file)
      options = { headers: true, col_sep: ',' }
      CSV.foreach(opened_file, **options) do |row|
  
        post_hash = {}
        post_hash[:title] = row['Title']
        post_hash[:body] = row['body']
        post_hash[:author] = row['author']
        post_hash[:likes] = row['like']
        post_hash[:comments] = row['comments']
  
        Post.find_or_create_by!(post_hash)
      end
    end
  end