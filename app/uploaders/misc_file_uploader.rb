# encoding: utf-8

class MiscFileUploader < CarrierWave::Uploader::Base

  storage :s3
  s3_access_policy :authenticated_read
  s3_bucket "new-files.jsasearch.net"
  process :set_content_type

  def set_content_type
    model.content_type = file.content_type
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(numbers txt csv xlsx xls doc docx pdf pages jpg jpeg png)
  end

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :s3

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end

end
