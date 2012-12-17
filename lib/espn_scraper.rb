require 'httparty'
require 'nokogiri'

def responding?
	HTTParty.get('http://espn.go.com/').code == 200
end

def down?
	!responding?
end
