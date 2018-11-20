class AttachmentUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.attachable.class.to_s.underscore}/#{model.attachable.code}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process resize_to_fit: [1000, 1000], :if => :image?
  process :store_dimensions, :if => :image?

  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb, :if => :image? do
    process resize_to_fit: [128, 128]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    # %w(jpg jpeg gif png pdf doc docx odt ppt pptx xls xlsx)
    Constants::FILE_EXTENSIONS
  end

  # def content_type_whitelist
  #   /image\//
  # end

  def content_type_blacklist
    ['application/text', 'application/json']
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    ActiveSupport::Inflector.transliterate(original_filename).gsub(' ', '_') if original_filename
  end

  private

    def store_dimensions
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end

  protected

    def image?(new_file)
      new_file.content_type.start_with? 'image'
    end
end
