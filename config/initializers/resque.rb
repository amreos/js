Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

ENV["REDISTOGO_URL"] ||= "redis://redistogo:afb76c3a76ea10c9eea24c1b722fd04c@cod.redistogo.com:9075/"

uri = URI.parse(ENV["REDISTOGO_URL"])

if Rails.env.production?
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = Redis.new(:host => 'localhost', :port => 6379)
end