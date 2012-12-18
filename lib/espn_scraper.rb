require 'httparty'
require 'nokogiri'

%w[ boilerplate teams ].each do |file|
  require "espn_scraper/#{ file }"
end