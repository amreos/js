# VCR.config do |c|
# 	c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + "/../fixtures/vcr_cassettes")
# 	c.stub_with :webmock
# end

# WebMock.disable_net_connect!

# module VcrHelpers
# 	def vcr_record_all
# 		if ENV['RECORD']
# 			WebMock.allow_net_connect!
# 			vcr_use_recording :record => :all
# 			WebMock.disable_net_connect!
# 		else
# 			vcr_use_recording
# 		end
# 	end

# 	def vcr_use_recording(options = {})
# 		use_vcr_cassette options.merge(:match_requests_on => [:host, :path, :method])
# 	end
# end

# RSpec.configure do |conf|
# 	conf.extend VCR::RSpec::Macros
# 	conf.extend VcrHelpers
# end