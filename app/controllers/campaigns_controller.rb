require "createsend"

class CampaignsController < ApplicationController
before_filter :load_cs_client
respond_to :js

def index
	@campaigns = @cs_client.campaigns.first(5)
	respond_with @campaigns
end

private
	def load_cs_client
		CreateSend.api_key 'b67962474079c4d814e7eed3d7af27df'
		client_key = '74ad1c033de4d76ab24fb772237a8ee4'
	 	@cs_client = CreateSend::Client.new("#{client_key}")
	end
end