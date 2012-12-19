module ESPN
  
  def self.get_scores(league, date_or_year, week=nil)
    scores_method = ["get_#{league}_scores_on", date_or_year, week].compact
    Scores.send *scores_method
  end
  
  
  
  module Scores
    
    def self.get_nba_scores_on(date)
      doc = markup_from_date 'nba', date
      home_away_parse doc, date
    end
    
    def self.get_mlb_scores_on(date)
      doc = markup_from_date 'mlb', date
      home_away_parse doc, date
    end
    
    def self.get_nhl_scores_on(date)
      doc = markup_from_date 'nhl', date
      winner_loser_parse doc, date
    end
    
    def self.get_nfl_scores_on(year, week)
      doc = markup_from_year_and_week 'nfl', year, week
      visitor_home_parse doc
    end
    
    private
    
    # Get Document
    
    def self.markup_from_date(league, date)
      day = date.to_s.gsub(/[^\d]+/, '')
      ESPN.get 'scores', league, "scoreboard?date=#{ day }"
    end
    
    def self.markup_from_year_and_week(league, year, week)
      http_params = %W[ seasonYear=#{year} seasonType=2 weekNumber=#{week} confId=80 ]
      ESPN.get 'scores', league, "scoreboard?#{ http_params.join('&') }"
    end
    
    # Parse Document
    
    def self.home_away_parse(doc, date)
      doc.css('.mod-scorebox.final-state').map do |game|
        game_info = { 'game_date' => date }
        ['home', 'away'].each do |home_away|
          team = game.at_css(".#{home_away} .team-name a")['href'].split('/').last
          game_info["#{home_away}_team"] = team
          
          score = game.at_css(".#{home_away} .finalScore").content.to_i
          game_info["#{home_away}_score"] = score
        end
        game_info
      end
    end
    
    def self.winner_loser_parse(doc, date)
      doc.css('.mod-scorebox-final').map do |game|
        game_info = { 'game_date' => date }
        
        teams = game.css('.team-name div').map do |td| 
          td.at_css('a')['href'].split('/').last 
        end
        game_info['away_team'], game_info['home_team'] = teams
        
        scores = game.css('.team-score').map { |td| td.at_css('span').content }
        game_info['away_score'], game_info['home_score'] = scores
        
        game_info
      end
    end
    
    def self.visitor_home_parse(doc)
      game_dates = doc.css('.games-date text()').map do |node|
        Date.parse(node.content)
      end
      game_scores = []
      doc.css('.gameDay-Container').each_with_index do |container, i|
        container.css('.mod-nfl-scorebox.final-state').each do |game|
          game_info = {}
          game_info['game_date'] = game_dates[i]
          game_info['home_team'] = game.at_css('.home .team-name a').content.dasherize
          game_info['home_score'] = game.at_css('.home .score .final').content.to_i
          game_info['away_team'] = game.at_css('.visitor .team-name a').content.dasherize
          game_info['away_score'] = game.at_css('.visitor .score .final').content.to_i
          game_scores.push game_info
        end
      end
      game_scores
    end
    
  end
end