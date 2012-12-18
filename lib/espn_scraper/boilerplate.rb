module ESPN
	
	def self.responding?
		HTTParty.get('http://espn.go.com/').code == 200
	end

	def self.down?
		!responding?
	end

	# Ex: espn_url('scores')
	#     espn_url('teams', 'nba')
	def self.url(*path)
		subdomain = (path.first == 'scores') ? path.shift : nil
		domain = [subdomain, 'espn', 'go', 'com'].compact.join('.')
		['http:/', domain, *path].join('/')
	end

	# Returns Nokogiri HTML document
	# Ex: espn_get('teams', 'nba')
	def self.get(*path)
		http_url = self.url(*path)
		response = HTTParty.get(http_url)
		unless response.code == 200
			raise "The url #{ http_url } from the path #{ path } did not return a valid page."
		else
			Nokogiri::HTML(response.body)
		end
	end
	
end



class String
	
	unless respond_to?(:dasherize)
		define_method(:dasherize) { downcase.gsub(/\s+/, '-') }
	end
	
end