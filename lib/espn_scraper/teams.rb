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
        name = parse_div_name(div)
        { name: name, data_name: div_data_name(name) }
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
      divisions = {}
	    get_divs(league.to_s.downcase).each do |division|
        key = div_data_name parse_div_name(division)
        divisions[key] = division.css('.ContentList').map do |team|
          team_elem = team.at_css('h5 a.bi')
          team_name = team_elem.content
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
    
    
    
    def get_divs(league)
      self.get(league, 'teams').css('.mt7')
    end

    def get_ncb_conferences
      self.get('ncb', 'conferences').css('.mod-content h5')
    end
    
    def parse_div_name(div)
      div.at_css('.mod-header h4 text()').content
    end
    
    def div_data_name(div_name)
      dasherize div_name.gsub(/division/i, '')
    end

  end
end