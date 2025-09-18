require 'test_helper'

class NflTest < EspnTest
  
  test 'gb data name is fixed' do
    scores = ESPN.get_nfl_scores(2012, 2)
    assert scores.any?, 'scores parsing failed'
    assert_equal 'gb', scores.first[:home_team]
  end

  test 'kc data name is fixed' do
    scores = ESPN.get_nfl_scores(2024, 1)
    assert scores.any?, 'scores parsing failed'
    assert scores.collect { |s| s[:home_team] }.include?('kc')
  end

  test 'nfl 2012 week 8 regular season' do
    starts_at = DateTime.parse('2012-10-26T00:20Z')
    expected = {
      league: 'nfl',
      game_date: starts_at,
      home_team: 'min',
      home_score: 17,
      away_team: 'tb',
      away_score: 36
    }
    scores = ESPN.get_nfl_scores(2012, 8)
    assert_equal expected, scores.first
  end
  
  test 'nfl 2012 week 7 regular season' do
    starts_at = DateTime.parse('2012-10-23T00:30:00+00:00')
    expected = {
      league: 'nfl',
      game_date: starts_at,
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