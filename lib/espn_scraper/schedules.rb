require 'date'

module ESPN

  class << self

    ## Currently schedules can be retrieved by day for: NBA and MLB
    ## ESPN Changing their website format - NFL, NHL, NCF, NCB to come
    ## Time: day specifically, must be in the future
    ## Time is returned Greenwich time

    # Example input:
    # def get_nba_schedules(Date.parse("April 12,2015"))

    # Example output:
    # {
    #  :away_team_name=>"Sacramento Kings",
    #  :away_data_name=>"sac",
    #  :home_team_name=>"Denver Nuggets",
    #  :home_data_name=>"den",
    #  :match_time=>"21:00"
    #  }

    def get_nba_schedules(date)
      league = __callee__.to_s.split("_")[1]
      Schedules.get_schedule(league, date)
    end

    def get_mlb_schedules(date)
      league = __callee__.to_s.split("_")[1]
      Schedules.get_schedule(league, date)
    end
  end

  module Schedules

    class << self

      def get_schedule(league, date)
        markup = markup_from_date(league, date)
        if games_available?(markup, date)
          teams_name_info = team_data_name(markup)
          dates_info = greenwich_time(markup)
          schedule = parse_schedule(teams_name_info, dates_info)
        else
          false
        end
      end

      private

      def games_available?(markup, date)
        if date <= Date.today
          puts "ERROR: Digging Into Past Games Not Allowed"
          false
        elsif markup == nil
          puts "ERROR: No Games Scheduled"
          false
        else
          true
        end
      end

      def markup_from_date(league, date)
        formatted_date = date.to_s.gsub(/[^\d]+/, '')
        all_markup_on_page = ESPN.get league, "schedule?date=#{ formatted_date }"
        markup_for_day = all_markup_on_page.at_css("tbody")
      end

      def team_data_name(markup)
        team_and_data_names=[]
        full_team_and_data_names=markup.children.css("abbr")
        full_team_and_data_names.each_with_index do |team_and_data_name, i|
          team_and_data_names << {team_name: team_and_data_name.attributes.values[0].value, data_name: team_and_data_name.text().downcase}
        end
        team_and_data_names.each_slice(2).to_a
      end

      def greenwich_time(markup)
        green_times_array=[]
        green_times = markup.children.css("td[data-date]")
        green_times.each do |green_time|
          green_time.attributes.each do |noko_value|
            if noko_value[0] == "data-date"
              green_times_array << grab_time(noko_value[1].value)
            end
          end
        end
        green_times_array
      end

      def grab_time(unformated_time)
        time_index_locator = unformated_time.split("").find_index("T")+1
        unformated_time.slice(time_index_locator..-2)
      end

      def parse_schedule(teams, times)
        future_games_no = times.count
        parsed_schedules = []
        parsed_schedule = {away_team_name: nil, away_data_name: nil, home_team_name: nil, home_data_name:nil, match_time: nil}

        future_games_no.times do |count|
          parse_schedule_dup = parsed_schedule.dup
          parse_schedule_dup[:away_team_name] = teams[count][0][:team_name]
          parse_schedule_dup[:away_data_name] = teams[count][0][:data_name]
          parse_schedule_dup[:home_team_name] = teams[count][1][:team_name]
          parse_schedule_dup[:home_data_name] = teams[count][1][:data_name]
          parse_schedule_dup[:match_time] = times[count]
          parsed_schedules << parse_schedule_dup
        end
        parsed_schedules
      end

    end
  end
end
