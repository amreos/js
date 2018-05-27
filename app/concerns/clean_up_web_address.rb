module CleanUpWebAddress

	private

	def add_protocol_to_web_address
	  if web_address.present? && web_address !~ /([a-zA-Z]+)\:\/\/(.*)/
	    self.web_address = "http://#{web_address}"
	    # "http://https://google.com".gsub(/htt(p|ps)\:\/\/?/,"")
	  end
	end
	
end