require 'uri'
require 'cgi'
require 'json'

module ESPN
  # For football
  SEASONS = {
    preseason: 1,
    regular_season: 2,
    postseason: 3
  }  

  mlb_ignores = %w( 
    florida-state u-of-south-florida georgetown fla.-southern northeastern boston-college 
    miami-florida florida-intl canada hanshin yomiuri sacramento springfield corpus-christi 
    round-rock carolina manatee-cc mexico cincinnati-(f) atlanta-(f) frisco toledo norfolk
    fort-myers tampa-bay-(f) nl-all-stars al-all-stars
  )
  
  nba_ignores = %w( west-all-stars east-all-stars )
  
  nhl_ignores = %w(
    hc-sparta frolunda hc-slovan ev-zug jokerit-helsinki hamburg-freezers adler-mannheim
    team-chara team-alfredsson
  )
  
  ncf_ignores = %w( paul-quinn san-diego-christian ferris-st notre-dame-college chaminade 
    w-new-mexico n-new-mexico tx-a&m-commerce nw-oklahoma-st )
  
  IGNORED_TEAMS = (mlb_ignores + nhl_ignores + nba_ignores + ncf_ignores).inject({}) do |h, team| 
    h.merge team => false 
  end
    
  DATA_NAME_EXCEPTIONS = {
    'nets' => 'bkn',
    'supersonics' => 'okc',
    'hornets' => 'no',
    
    'marlins' => 'mia'
  }.merge(IGNORED_TEAMS)
  
  DATA_NAME_FIXES = {
    'nfl' => {
      'nwe' => 'ne',
      'kan' => 'kc',
      'was' => 'wsh',
      'nor' => 'no',
      'gnb' => 'gb',
      'sfo' => 'sf',
      'tam' => 'tb',
      'sdg' => 'sd'
    },
    'mlb' => {},
    'nba' => {},
    'nhl' => {},
    'ncf' => {},
    'ncb' => {}
  }

  # Example output:
  # {
  #   league: "nfl",
  #   game_date: #<Date: 2013-01-05 ((2456298j,0s,0n),+0s,2299161j)>,
  #   home_team: "sea",
  #   home_score: 48,
  #   away_team: "min",
  #   away_score: 27
  # }
  
  class << self
    
    def get_nfl_scores(year, week)
      markup = Scores.markup_from_year_and_week('nfl', year, week)
      scores = Scores.visitor_home_parse(markup, 'nfl')
      add_league_and_fixes(scores, 'nfl')
      scores
    end
    
    def get_mlb_scores(date)
      markup = Scores.markup_from_date('mlb', date)
      scores = Scores.home_away_parse(markup, date)
      scores.each { |report| report[:league] = 'mlb' }
      scores
    end
    
    def get_nba_scores(date)
      markup = Scores.markup_from_date('nba', date)
      scores = Scores.home_away_parse(markup, date)
      scores.each { |report| report[:league] = 'nba' }
      scores
    end
    
    def get_nhl_scores(date)
      markup = Scores.markup_from_date('nhl', date)
      scores = Scores.winner_loser_parse(markup, date)
      scores.each { |report| report[:league] = 'nhl' }
      scores
    end
    
    def get_ncf_scores(year, week)
      markup = Scores.markup_from_year_and_week('college-football', year, week)
      scores = Scores.ncf_parse(markup)
      scores.each { |report| report[:league] = 'college-football' }
      scores
    end
    
    alias_method :get_college_football_scores, :get_ncf_scores
    
    def get_ncb_scores(date)
      markup = Scores.markup_from_date('ncb', date)
      scores = Scores.visitor_home_parse(markup, 'ncb')
      scores.each { |report| report.merge! league: 'mens-college-basketball', game_date: date }
      scores
    end
    
    alias_method :get_college_basketball_scores, :get_ncb_scores    
    
    def add_league_and_fixes(scores, league)
      scores.each do |report|
        report[:league] = league
        [:home_team, :away_team].each do |sym|
          team = report[sym]
          report[sym] = DATA_NAME_FIXES[league][team] || team
        end
      end
    end
  end  



  module Scores
    class << self
    
      # Get Markup
    
      def markup_from_year_and_week(league, year, week)
        ESPN.get 'scores', league, "scoreboard/_/group/80/year/#{year}/seasontype/2/week/#{week}"
      end
    
      def markup_from_date(league, date)
        day = date.to_s.gsub(/[^\d]+/, '')
        ESPN.get 'scores', league, "scoreboard?date=#{ day }"
      end
    
      # parsing strategies
    
      def visitor_home_parse(doc, league)
        game_dates = doc.css('.games-date text()').map do |node|
          Date.parse(node.content)
        end
        game_scores = []
        doc.css('.gameDay-Container').each_with_index do |container, i|
          container.css(".mod-#{league}-scorebox.final-state").each do |game|
            game_info = {}
            game_info[:game_date]  = game_dates[i]
            game_info[:home_team]  = self.parse_data_name_from game.at_css('.home .team-name')
            game_info[:away_team]  = self.parse_data_name_from game.at_css('.visitor .team-name')
            game_info[:home_score] = game.at_css('.home .score .final').content.to_i
            game_info[:away_score] = game.at_css('.visitor .score .final').content.to_i
            game_scores.push game_info
          end
        end
        game_scores
      end
    
      def home_away_parse(doc, date)
        scores = []
        games = []
        espn_regex = /window\.espn\.scoreboardData \t= (\{.*?\});/
        doc.xpath("//script").each do |script_section|
          if script_section.content =~ espn_regex
            espn_data = JSON.parse(espn_regex.match(script_section.content)[1])
            games = espn_data['events']
            break
          end
        end
        games.each do |game|
          # Game must be regular season
          next unless game['season']['type'] == 2
          score = { game_date: date }
          competition = game['competitions'].first
          # Score must be final
          if competition['status']['type']['detail'] =~ /^Final/
            competition['competitors'].each do |competitor|
              if competitor['homeAway'] == 'home'
                score[:home_team] = competitor['team']['abbreviation'].downcase
                score[:home_score] = competitor['score'].to_i
              else
                score[:away_team] = competitor['team']['abbreviation'].downcase
                score[:away_score] = competitor['score'].to_i
              end
            end
            scores << score
          end
        end
        scores
      end
      
      def ncf_parse(doc)
        scores = []
        games = []
        espn_regex = /window\.espn\.scoreboardData \t= (\{.*?\});/
        doc.xpath("//script").each do |script_section|
          if script_section.content =~ espn_regex
            espn_data = JSON.parse(espn_regex.match(script_section.content)[1])
            games = espn_data['events']
            break
          end
        end
        games.each do |game|
          score = { league: 'college-football' }
          competition = game['competitions'].first
          date = DateTime.parse(competition['startDate'])
          date = date.new_offset('-06:00')
          score[:game_date] = date.to_date
          # Score must be final
          if competition['status']['type']['detail'] =~ /^Final/
            competition['competitors'].each do |competitor|
              if competitor['homeAway'] == 'home'
                score[:home_team] = competitor['team']['id'].downcase
                score[:home_score] = competitor['score'].to_i
                else
                score[:away_team] = competitor['team']['id'].downcase
                score[:away_score] = competitor['score'].to_i
              end
            end
            scores << score
          end
        end
        scores
      end
    
      def winner_loser_parse(doc, date)
        doc.css('.mod-scorebox-final').map do |game|
          game_info = { game_date: date }
          teams = game.css('td.team-name:not([colspan])').map { |td| parse_data_name_from(td) }
          game_info[:away_team], game_info[:home_team] = teams
          scores = game.css('.team-score').map { |td| td.at_css('span').content.to_i }
          game_info[:away_score], game_info[:home_score] = scores
          game_info
        end
      end
    
      # parsing helpers
    
      def parse_data_name_from(container)
        if container.at_css('a')
          link = container.at_css('a')['href']
          self.data_name_from(link)
        else
          if container.at_css('div')
            name = container.at_css('div text()').content
          elsif container.at_css('span')
            name = container.at_css('span text()').content
          else
            name = container.at_css('text()').content
          end
          ESPN::DATA_NAME_EXCEPTIONS[ ESPN.dasherize(name) ]
        end
      end
    
      def data_name_from(link)
        encoded_link = URI::encode(link.strip)
        query = URI::parse(encoded_link).query
        if query
          CGI::parse(query)['team'].first
        else
          link.split('/')[-2]
        end
      end
    
    end
  end
end