require 'uri'
require 'cgi'
require 'json'

module ESPN
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
      'sdg' => 'lac',
      'sd' => 'lac'
    },
    'mlb' => {},
    'nba' => {},
    'nhl' => {},
    'ncf' => {},
    'ncb' => {
          'mur' => 'murr'
        }
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

    # Compute the anchor date for a given NFL regular-season week.
    # Returns a Date representing the Thursday of that week (when TNF is played).
    def nfl_week_start_date(year, week)
      # NFL Week 1 is the week containing the first Thursday after September 1st of the given year.
      # Find first Thursday on or after Sep 4 (covers modern era). Then add (week-1)*7 days.
      sep4 = Date.new(year, 9, 4)
      # wday: 0=Sunday ... 4=Thursday ... 6=Saturday
      days_until_thu = (4 - sep4.wday) % 7
      first_thu = sep4 + days_until_thu
      target_thu = first_thu + (week - 1) * 7
      target_thu
    end

    def get_nfl_scores(year, week)
      # Build the full NFL week by aggregating daily ESPN API scoreboards
      start_thu = nfl_week_start_date(year, week)
      # Include Thursday through Tuesday (covers TNF thru MNF even with late/UTC spillover)
      days = (0..5).map { |d| start_thu + d }
      docs = days.map { |d| Scores.markup_from_date('nfl', d) }
      combined = { 'events' => docs.flat_map { |doc| doc.is_a?(Hash) ? (doc['events'] || []) : [] } }
      scores = Scores.home_away_parse(combined, nil, 'nfl')
      # Ensure deterministic order (oldest to newest) to satisfy tests expecting first/last of the week
      scores.sort_by! { |s| s[:game_date] }
      add_league_and_fixes(scores, 'nfl')
      scores
    end

    def get_mlb_scores(date)
      markup = Scores.markup_from_date('mlb', date)
      scores = Scores.home_away_parse(markup, date, 'mlb')
      scores.each { |report| report[:league] = 'mlb' }
      scores
    end

    def get_nba_scores(date)
      markup = Scores.markup_from_date('nba', date)
      scores = Scores.home_away_parse(markup, date, 'nba')
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
      markup = Scores.markup_from_year_and_week('college-football', year, week, 80)
      scores = Scores.ncf_parse(markup)
      scores.each { |report| report[:league] = 'college-football' }
      scores
    end

    alias_method :get_college_football_scores, :get_ncf_scores

    def get_ncb_scores(date, conference_id)
      markup = Scores.markup_from_date_and_conference('ncb', date, conference_id)
      scores = Scores.home_away_parse(markup, date, 'ncb')
      # Apply team abbreviation fixes for NCB without changing league key
      fixes = DATA_NAME_FIXES['ncb'] || {}
      scores.each do |report|
        [:home_team, :away_team].each do |sym|
          team = report[sym]
          report[sym] = fixes[team] || team
        end
        report.merge! league: 'mens-college-basketball', game_date: date
      end
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

      def markup_from_year_and_week(league, year, week, group=nil)
        tz = 'America/New_York'
        base = 'https://site.web.api.espn.com/apis/site/v2/sports'
        api_sport = case league
                    when 'mlb' then 'baseball/mlb'
                    when 'nba' then 'basketball/nba'
                    when 'nfl' then 'football/nfl'
                    when 'nhl' then 'hockey/nhl'
                    when 'ncb' then 'basketball/mens-college-basketball'
                    when 'college-football','ncf' then 'football/college-football'
                    else "#{league}"
                    end
        url = if group
          "#{base}/#{api_sport}/scoreboard?seasontype=2&week=#{week}&year=#{year}&group=#{group}&tz=#{CGI.escape(tz)}"
        else
          "#{base}/#{api_sport}/scoreboard?seasontype=2&week=#{week}&year=#{year}&tz=#{CGI.escape(tz)}"
        end
        response = HTTParty.get(url)
        raise ArgumentError, "Error getting #{url}. Status code: #{response.code}. Body: #{response.body}" unless response.code == 200
        JSON.parse(response.body)
      end

      def markup_from_date(league, date)
        day = date.to_s.gsub(/[^\d]+/, '')
        tz = 'America/New_York'
        base = 'https://site.web.api.espn.com/apis/site/v2/sports'
        api_sport = case league
                    when 'mlb' then 'baseball/mlb'
                    when 'nba' then 'basketball/nba'
                    when 'nfl' then 'football/nfl'
                    when 'nhl' then 'hockey/nhl'
                    when 'ncb' then 'basketball/mens-college-basketball'
                    when 'college-football','ncf' then 'football/college-football'
                    else "#{league}"
                    end
        url = "#{base}/#{api_sport}/scoreboard?dates=#{day}&tz=#{CGI.escape(tz)}"
        response = HTTParty.get(url)
        raise ArgumentError, "Error getting #{url}. Status code: #{response.code}. Body: #{response.body}" unless response.code == 200
        JSON.parse(response.body)
      end

      def markup_from_date_and_conference(league, date, conference_id)
        day = date.to_s.gsub(/[^\d]+/, '')
        tz = 'America/New_York'
        base = 'https://site.web.api.espn.com/apis/site/v2/sports'
        api_sport = case league
                    when 'ncb','mens-college-basketball' then 'basketball/mens-college-basketball'
                    else 'basketball/mens-college-basketball'
                    end
        url = "#{base}/#{api_sport}/scoreboard?dates=#{day}&groups=#{conference_id}&tz=#{CGI.escape(tz)}"
        response = HTTParty.get(url)
        raise ArgumentError, "Error getting #{url}. Status code: #{response.code}. Body: #{response.body}" unless response.code == 200
        JSON.parse(response.body)
      end

      # parsing strategies

      def home_away_parse(doc, date, league)
        # doc is expected to be a parsed JSON hash returned by markup_from_* methods
        scores = []
        events = doc.is_a?(Hash) ? (doc['events'] || []) : []

        events.each do |game|
          # Filter by regular/postseason if present
          if game['season'] && game['season']['type']
            next unless game['season']['type'] == SEASONS[:regular_season] || game['season']['type'] == SEASONS[:postseason]
          end

          # Skip suspended games that started on the query date
          comp = game['competitions']&.first || {}
          game_date_iso = comp['startDate'] || game['date']
          was_suspended = comp['wasSuspended']
          if was_suspended && game_date_iso && date
            game_start = DateTime.parse(game_date_iso)
            next if game_start.to_date == date
          end

          competition = game['competitions']&.first
          next unless competition

          status_detail = competition.dig('status', 'type', 'detail').to_s
          next unless status_detail =~ /^Final/

          score = {}
          (competition['competitors'] || []).each do |competitor|
            team = competitor['team'] || {}
            abbr = (team['abbreviation'] || team['id'] || '').to_s.downcase
            if competitor['homeAway'] == 'home'
              score[:home_team] = abbr
              score[:home_score] = competitor['score'].to_i
            else
              score[:away_team] = abbr
              score[:away_score] = competitor['score'].to_i
            end
          end
          score[:game_date] = DateTime.parse(competition['startDate'] || game['date'])
          scores << score if score[:home_team] && score[:away_team]
        end
        scores
      end

      def ncf_parse(doc)
        # doc is expected to be a parsed JSON hash returned by markup_from_* methods
        scores = []
        games = doc.is_a?(Hash) ? (doc['events'] || []) : []
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
        # For NHL, parse the JSON events and return away/home scores
        events = doc.is_a?(Hash) ? (doc['events'] || []) : []
        events.each_with_object([]) do |game, arr|
          comp = game['competitions']&.first
          next unless comp
          detail = comp.dig('status', 'type', 'detail').to_s
          next unless detail =~ /^Final/
          info = { game_date: date }
          (comp['competitors'] || []).each do |competitor|
            team = competitor['team'] || {}
            abbr = (team['abbreviation'] || team['id'] || '').to_s.downcase
            if competitor['homeAway'] == 'home'
              info[:home_team] = abbr
              info[:home_score] = competitor['score'].to_i
            else
              info[:away_team] = abbr
              info[:away_score] = competitor['score'].to_i
            end
          end
          arr << info if info[:home_team] && info[:away_team]
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
