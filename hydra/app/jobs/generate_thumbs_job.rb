class GenerateThumbsJob < ApplicationJob
  include ImportLibrary

  queue_as :import
  attr_accessor :record

  IMAGE_PATH = "/home/hydra/tmp/images"
  THUMBNAIL_PATH = "/home/hydra/tmp/thumbnails"

  def perform(identifier)
    find_record(identifier)
    # Ignore if record type is sound or moving image
    return if av_resource?
    return record.thumbnail_file = nil if record.preview.blank?

    job = pdf_uri? ? GeneratePdfThumbsJob : GenerateImageThumbsJob
    job.perform_later(identifier)
  end

  private

    def find_record(identifier)
      self.record = Acda.where(identifier: identifier).first
    end

    def av_resource?
      (record.dc_type == 'Sound') || (record.dc_type.include? 'Moving')
    end

    def pdf_uri?
      record.preview.include?('pdf')
    end

    def process_file(file_path)
      setup_directories
      return unless download_file(file_path)

      file_path = yield(record) if block_given?
      set_image_and_thumbnail(file_path)
    end

    def setup_directories
      tmp_paths.each { |path| FileUtils.mkdir_p(path) unless File.exist?(path) }
    end

    def tmp_paths
      [IMAGE_PATH, THUMBNAIL_PATH]
    end

    def download_file(file_path)
      file = URI.open(record.preview)
      File.open(file_path, 'wb') { |f| IO.copy_stream(file, f) }
      true
    rescue Errno::ENOENT, OpenURI::HTTPError, SocketError => e
      log_error(e.message)
      record.thumbnail_file = nil
      false
    end

    def set_image_and_thumbnail(image_file_path)
      image_file_path = yield if block_given?
      return log_error("The file is not a valid format.") unless valid_format?(image_file_path, 'image')

      record.files.build unless record.files.any?

      ImportLibrary.set_file(record.build_image_file, 'application/jpg', image_file_path)
      thumbnail_file_path = create_thumbnail(record.identifier, image_file_path)
      ImportLibrary.set_file(record.build_thumbnail_file, 'application/jpg', thumbnail_file_path)
      record.save!

      cleanup_files!(record.identifier)
    end

    def valid_format?(file_path, format)
      mime_type = `file --brief --mime-type #{Shellwords.escape(file_path)}`.strip
      mime_type.include?(format)
    end

    def create_thumbnail(identifier, image_file_path)
      thumbnail_file_path = File.join(THUMBNAIL_PATH, "#{identifier}.jpg")
      MiniMagick::Tool::Convert.new do |convert|
        convert.thumbnail '150x150'
        convert.format 'jpg'
        convert.background 'white'
        convert.density 300
        convert.quality 100
        convert << image_file_path
        convert << thumbnail_file_path
      end
      thumbnail_file_path
    end

    def log_error(message)
      Rails.logger.error "Error downloading file for #{record.identifier}: #{message}"
    end

    def cleanup_files!(identifier)
      tmp_paths.each do |path|
        FileUtils.rm_f(Dir.glob("#{path}/#{identifier}*"))
      end
    end
end
