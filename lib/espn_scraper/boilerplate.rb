require 'httparty'
require 'nokogiri'

module ESPN
  class << self

    def responding?
      HTTParty.get('http://www.espn.com').code == 200
    end

    def down?
      !responding?
    end

    # Ex: ESPN.url('scores')
    #     ESPN.url('teams', 'nba')
    def url(*path)
      path.shift if path.first == 'scores'
      ['http://www.espn.com', *path].join('/')
    end

    # Returns Nokogiri HTML document
    # Ex: ESPN.get('teams', 'nba')
    def get(*path)
      http_url = self.url(*path)
      response = HTTParty.get(http_url)
      if response.code == 200
        Nokogiri::HTML(response.body)
      else
        raise ArgumentError, error_message(url, path)
      end
    end

    def dasherize(str)
      str.strip.downcase.gsub(/\s+/, '-')
    end


    private



    def error_message(url, path)
      "The url #{url} from the path #{path} did not return a valid page."
    end

  end
end

