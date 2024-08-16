class Post < ApplicationRecord
    require 'csv'
    def self.to_csv
        posts = all
        CSV.generate do |csv|
            csv << column_names
            posts.each do |post|
                csv << post.attributes.values_at(*column_names)
            end
        end
    end
end
