class GeneratePdfThumbsJob < GenerateThumbsJob
  PDF_PATH = "/home/hydra/tmp/pdf"

  def perform(identifier)
    find_record(identifier)
    pdf_file_path = File.join(PDF_PATH, "#{identifier}.pdf")
    process_file(pdf_file_path) { convert_pdf_to_image(pdf_file_path) }
  end

  private

    def tmp_paths
      super + [PDF_PATH]
    end

    def convert_pdf_to_image(pdf_file_path)
      return log_error(record, "The file is not a valid PDF.") unless valid_format?(pdf_file_path, 'pdf')

      image_file_path = File.join(IMAGE_PATH, "#{record.identifier}.jpg")
      MiniMagick::Tool::Convert.new do |convert|
        convert.format 'jpg'
        convert.background 'white'
        convert.density 300
        convert.quality 100
        # Add page selection to convert the first page of the PDF if it's multi-page
        convert << "#{pdf_file_path}[0]"
        convert << image_file_path
      end
      image_file_path
    end
end
