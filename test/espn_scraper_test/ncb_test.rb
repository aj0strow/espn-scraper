require 'test_helper'

class NcbTest < EspnTest
  
  test 'mens college basketball march 15th murray state beats colorado state' do
    day = Date.parse('2012-03-15')
    league = 'mens-college-basketball'
    expected = {
      league: league,
      game_date: day,
      home_team: 'murr',
      home_score: 58,
      away_team: 'csu',
      away_score: 41,
      season_type: ESPN::SEASONS[:postseason],
      game_status: ESPN::GAME_STATUSES[:completed]
    }
    mountain_west_conf = ESPN.get_conferences_in_ncb.select {|c| c[:name] == 'Mountain West' }.first
    scores = ESPN.get_college_basketball_scores(day, mountain_west_conf[:data_name])
    assert_equal expected, scores.first
  end
  

  test 'random ncb dates' do
    random_days.each do |day|
      random_conf = ESPN.get_conferences_in_ncb.sample
      scores = ESPN.get_college_basketball_scores(day, random_conf[:data_name])
      assert all_names_present?(scores), "Error on #{day} for college basketball"
    end
  end
  
end