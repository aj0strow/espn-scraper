require 'json'

module ESPN
  class << self
    
    def leagues
      @leagues || %w(nfl mlb nba nhl ncf ncb)
    end
    
    def leagues=(leagues)
      @leagues = leagues
    end
    
    def get_divisions
      divisions = {}
      leagues.each do |league|
        divisions[league] = get_divisions_in(league)
      end
      divisions
    end
    
    def get_divisions_in(league)
      get_divs(league).map do |div|
        { name: div['name'], data_name: div_data_name(div['name']) }
      end
    end

    def get_conferences_in_ncb
      get_ncb_conferences.map do |element|
        name = element.content
        data_name = $1 if element.children[0].attributes['href'].value =~ /confId=(\d+)/
        { name: name, data_name: data_name }
      end
    end
    
    def get_teams_in(league)
	    get_divs(league.to_s.downcase)
    end
    
    
    
    private
    
    
    
    def get_divs(league)
      # Return nested DOM object with divisions, then teams on lower level
      divisions = {}

      # Make request
      response = self.get(league, 'teams')

      # Parse a handy JS object on the pages
      js_match = response.content.match /window\['__espnfitt__'\]\s*=\s*(\{.+\})/
      if js_match
        js_data = JSON.parse(js_match[1])
        return_divs = js_data['page']['content']['teams'][league]
        alt_return_divs = js_data['page']['content']['leagueTeams']['columns']

        # Use the "teams" key for most sports
        if !return_divs.nil?
          # Parse each division
          return_divs.each do |division|
            teams = []
            division_key = dasherize division['name']

            # Parse each team
            division['teams'].each do |team|
              teams << {name: team['name'], data_name: team['abbrev']}
            end

            # Save division
            divisions[division_key] = teams
          end

        # Use the "leagueTeams" key for a few other sports
        elsif !alt_return_divs.nil?
          # Flatten the columns
          groups = alt_return_divs.map { |x| x["groups"] }.flatten(1)

          # Parse each division
          groups.each do |group|
            key = dasherize group['nm']
            next if key.include? '-division'
            teams = []

            # Parse each team
            group['tms'].each do |team|
              teams << {name: team['n'], data_name: team['id']}
            end

            # Save division
            divisions[key] = teams
          end
        end
      end
      divisions
    end

    def get_ncb_conferences
      self.get('ncb', 'conferences').css('.mod-content h5')
    end

    def div_data_name(div_name)
      dasherize div_name.gsub(/division/i, '')
    end

  end
end