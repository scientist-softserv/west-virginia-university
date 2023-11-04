class GenerateImageThumbsJob < GenerateThumbsJob
  def perform(identifier)
    find_record(identifier)
    image_file_path = File.join(IMAGE_PATH, "#{identifier}.jpg")
    process_file(image_file_path)
  end
end
