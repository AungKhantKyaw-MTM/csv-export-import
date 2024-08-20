class CsvJob
  include Sidekiq::Job

  def perform(file_path)
    CsvImportService.new.call(File.read(file_path))
  end
end
