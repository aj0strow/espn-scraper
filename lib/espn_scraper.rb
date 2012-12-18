require 'httparty'
require 'nokogiri'

%w[ boilerplate ].each do |file|
	require "espn_scraper/#{ file }"
end

def get_teams_in(league)
	markup = HTTParty.get("http://espn.go.com/#{ league }/teams").body
	puts markup[0..100]
end