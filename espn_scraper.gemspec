$:.push File.expand_path("../lib", __FILE__)
require 'espn_scraper/version'

Gem::Specification.new do |s|
  s.name        = 'espn_scraper'
  s.version     = ESPN::VERSION
  s.date        = '2013-04-07'
  s.licenses    = %w[ MIT ]
  s.summary     = 'ESPN Scraper'
  s.description = 'a simple scraping api for espn stats and data'
  s.authors     = %w[ aj0strow ]
  s.email       = 'alexander.ostrow@gmail.com'
  s.homepage    = 'http://github.com/aj0strow/espn-scraper'
  
  s.add_dependency 'httparty'
  s.add_dependency 'nokogiri'
  
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- test`.split("\n")
end
