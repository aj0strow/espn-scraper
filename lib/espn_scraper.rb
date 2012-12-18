require 'httparty'
require 'nokogiri'

def responding?
	HTTParty.get('http://espn.go.com/').code == 200
end

def down?
	!responding?
end

def espn_url(*path)
	subdomain = (path.first == 'scores') ? path.shift : nil
	domain = [subdomain, 'espn', 'go', 'com'].compact.join('.')
	['http:/', domain, *path].join('/')
end

def get_teams_in(league)
	markup = HTTParty.get("http://espn.go.com/#{ league }/teams").body
	puts markup[0..100]
end