class GenerateThumbsJob < ApplicationJob
  queue_as :import

  def perform(identifier)
    # find record
    record = Acda.where(identifier: identifier).first

    # Ignore if record type is sound or moving image
    return if record.dc_type.nil?
    return if ((record.dc_type == 'Sound') || (record.dc_type.include? 'Moving'))

    if record.preview.blank?
      record.thumbnail_file = nil
      record.image_file = nil
      return
    end

    # if record.preview is a pdf
    if record.preview.include? 'pdf'
      GeneratePdfThumbsJob.perform_later(identifier)
    # tesing thumbnail generation for images from remote files
    else
      GenerateImageThumbsJob.perform_later(identifier)
    end
  end

end
