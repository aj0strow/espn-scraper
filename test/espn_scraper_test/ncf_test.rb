require 'test_helper'

class NcfTest < EspnTest
  
  test 'college football 2012 week 9 regular season' do
    starts_at = DateTime.parse('2012-10-25T00:00:00+00:00')
    expected = {
      league: 'college-football',
      game_date: starts_at,
      home_team: '154',
      home_score: 13,
      away_team: '228',
      away_score: 42
    }
    scores = ESPN.get_college_football_scores(2012, 9)
    assert_includes scores, expected
  end
  
  test 'looking for a break' do
    random_days.each do |week|
      scores = ESPN.get_college_football_scores(2012, week)
      assert all_names_present?(scores), "!!! error in week #{week}"
    end
  end

end