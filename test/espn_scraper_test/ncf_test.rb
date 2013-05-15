require 'test_helper'

class NcfTest < EspnTest
  
  test 'college football 2012 week 9 regular season' do
    expected = {
      league: 'college-football',
      game_date: Date.parse('Oct 23, 2012'),
      home_team: '309',
      home_score: 27,
      away_team: '2032',
      away_score: 50
    }
    scores = ESPN.get_college_football_scores(2012, 9)
    assert_equal expected, scores.first
  end
  
  test 'looking for a break' do
    random_days.each do |week|
      scores = ESPN.get_college_football_scores(2012, week)
      assert all_names_present?(scores), "!!! error in week #{week}"
    end
  end

end