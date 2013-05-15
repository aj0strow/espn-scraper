require 'test_helper'

class NcbTest < EspnTest
  
  test 'mens college basketball march 15th murray state beats colorado state' do
    day = Date.parse('Mar 15, 2012')
    expected = {
      league: 'mens-college-basketball',
      game_date: day,
      home_team: '93',
      home_score: 58,
      away_team: '36',
      away_score: 41
    }
    scores = ESPN.get_college_basketball_scores(day)
    assert_equal expected, scores.first
  end
  

  test 'random ncb dates' do
    random_days.each do |day|
      scores = ESPN.get_college_basketball_scores(day)
      assert all_names_present?(scores), "Error on #{day} for college basketball"
    end
  end
  
end