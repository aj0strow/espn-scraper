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
      fetch_division_sections(league).map do |div|
        name = parse_division_name(div)
        { name: name, data_name: div_data_name(name) }
      end
    end

    def get_conferences_in_ncb
      get_ncb_conferences.map do |element|
        name = element.text
        data_name = $1.to_s if element.attributes['value'].value =~ /^(\d+)$/
        { name: name, data_name: data_name }
      end
    end
    
    def get_teams_in(league)
      divisions = {}

      # iterate through divisions
      fetch_division_sections(league.to_s.downcase).each do |division|
        key = div_data_name parse_division_name(division)

        # iterate through teams in the division
        divisions[key] = division.css('div .ContentList__Item').map do |team|
          team_elem = team.at_css('.AnchorLink')
          team_name = team_elem.at_css('img')['title']
          data_name, slug = team_elem['href'].split('/').last(2)
          
          slug.sub! dasherize(team_name), ''
          team_name.sub! /\(.*\)/, ''
          
          name_adds = slug.split('-').reject(&:empty?).each(&:capitalize!)
          name = name_adds.unshift(team_name).join(' ').strip.gsub(/\s+/, ' ')
          { name: name, data_name: data_name }
        end
      end
      divisions
    end
    
    
    
    private
    
    
    
    # Backwards-compatible: fetch raw division sections for a specific league
    def fetch_division_sections(league)
      self.get(league, 'teams').css('div.mt7')
    end

    def get_ncb_conferences
      conferences = self.get('mens-college-basketball', 'teams').at_css('.dropdown__select').children
      # don't include the first option because its just "all conferences"
      conferences.drop(1)
    end
    
    def parse_division_name(div)
      div.at_css('.headline text()').content
    end
    
    def div_data_name(div_name)
      dasherize div_name.gsub(/division/i, '')
    end

  end
end