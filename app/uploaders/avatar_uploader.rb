# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :s3
  s3_access_policy :public_read
  # s3_access_policy :authenticated_read
  s3_bucket "new-images.jsasearch.net"

  process :resize_to_fill => [300, 300]

  version :thumb do
    process :resize_to_fill => [32,32]
  end

  # def set_content_type
  #   model.content_type = file.content_type
  # end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def image_path_with_ssl
    "https://s3.amazonaws.com/#{s3_bucket}/#{current_path}"
  end

  def thumb_path_with_ssl
    "https://s3.amazonaws.com/#{s3_bucket}/#{thumb.path}"
  end


  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

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

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end

end
