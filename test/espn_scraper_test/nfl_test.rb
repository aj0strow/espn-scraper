require 'test_helper'

class NflTest < EspnTest
  
  test 'data names are fixed' do
    score = ESPN.get_nfl_scores(2012, 2).first
    assert_equal 'gb', score[:home_team]
  end

  test 'nfl 2012 week 8 regular season' do
    expected = {
      league: 'nfl',
      game_date: Date.parse('Oct 25, 2012'),
      home_team: 'min',
      home_score: 17,
      away_team: 'tb',
      away_score: 36
    }
    scores = ESPN.get_nfl_scores(2012, 8)
    assert_equal expected, scores.first
  end
  
  test 'nfl 2012 week 7 regular season' do
    expected = {
      league: 'nfl',
      game_date: Date.parse('Oct 22, 2012'),
      home_team: 'chi',
      home_score: 13,
      away_team: 'det',
      away_score: 7
    }
    scores = ESPN.get_nfl_scores(2012, 7)
    assert_equal expected, scores.last
  end
  
  test 'looking for a break' do
    random_weeks.each do |week|
      scores = ESPN.get_nfl_scores(2012, week)
      assert all_names_present?(scores), "!!! error in week #{week}"
    end
  end

end