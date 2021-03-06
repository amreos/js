CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'

  config.s3_access_key_id = ENV['S3_ACCESS_KEY_ID']
  config.s3_secret_access_key = ENV['S3_SECRET_ACCESS_KEY']
  config.s3_authentication_timeout = 432000
  config.s3_use_ssl = true 
end
