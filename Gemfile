source 'http://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.21'

gem 'rake', '0.9.2'
gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"
gem 'haml'
gem 'jquery-rails', '~> 2.0'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'fog'
gem 'validates_timeliness', '~> 3.0.2'
gem 'chronic'
gem 'devise'
gem 'geocoder'
gem "resque", "~> 1.19.0"
gem 'kaminari'
gem 'httparty'
gem "mini_magick"
gem "createsend"
gem 'heroku'
gem 'psych', '~> 2.0.5'

gem 'unicorn'
gem 'foreman'

gem 'rails_12factor', group: :production

group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
  gem "zurb-foundation"
end

group :development, :test do
	gem "factory_girl_rails", "~> 1.2"
  gem 'fakeweb'
  gem 'rspec-rails', '~>2.6'
  gem 'mongoid-rspec'
  gem 'launchy'
  gem 'pry'
  gem 'capybara'
  gem 'letter_opener'
  gem 'guard-livereload'
  gem "dotenv-rails", "~> 0.9.0"
  #gem 'vcr'
  #gem 'webmock'
end

group :test, :darwin do
  gem 'rb-fsevent'
end

group :test do
  gem 'resque_spec'
end
