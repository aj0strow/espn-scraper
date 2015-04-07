require 'test_helper'
require 'date'

class SchedulesTest < EspnTest

  test 'schedules in the past will not be displayed' do
    assert_equal ESPN.get_nba_schedules(Date.parse('April 03, 2015')), false
  end

  test 'schedules on dates with no games will not be displayed' do
    assert_equal ESPN.get_nba_schedules(Date.parse('June 06, 2020')), false
  end

  if Date.parse('April 12, 2015') > Date.today
    test 'there are games on the follow date for NBA' do
      assert_test = ESPN.get_nba_schedules(Date.parse('April 12, 2015'))
      assert assert_test.instance_of? Array
      assert assert_test.count == 9
    end

    test 'NBA actual schedules match expected' do
      assert_test = ESPN.get_nba_schedules(Date.parse('April 12, 2015'))
      assert_equal assert_test[0][:away_team_name], "Brooklyn Nets"
      assert_equal assert_test[0][:home_team_name], "Milwaukee Bucks"
      assert_equal assert_test[0][:match_time], "19:00"

      assert_equal assert_test[-1][:away_team_name], "Dallas Mavericks"
      assert_equal assert_test[-1][:home_team_name], "Los Angeles Lakers"
      assert_equal assert_test[-1][:match_time], "01:30"
    end
  end

  if Date.parse('April 13, 2015') > Date.today
    test 'there are games on the follow date for MLB' do
      assert_test = ESPN.get_mlb_schedules(Date.parse('April 13, 2015'))
      assert assert_test.instance_of? Array
      assert assert_test.count == 14
    end

    test 'MLB actual schedules match expected' do
      assert_test = ESPN.get_mlb_schedules(Date.parse('April 13, 2015'))
      assert_equal assert_test[0][:away_team_name], "Philadelphia Phillies"
      assert_equal assert_test[0][:home_team_name], "New York Mets"
      assert_equal assert_test[0][:match_time], "17:10"

      assert_equal assert_test[-1][:away_team_name], "Arizona Diamondbacks"
      assert_equal assert_test[-1][:home_team_name], "San Diego Padres"
      assert_equal assert_test[-1][:match_time], "02:10"
    end
  end
end