require 'test_helper'

class MlbTest < EspnTest
  
  test 'mlb august 13th 2012 yankees beat rangers' do
    day = Date.parse('Aug 13, 2012')
    expected = {
      league: 'mlb',
      game_date: day,
      home_team: 'nyy',
      home_score: 8,
      away_team: 'tex',
      away_score: 2
    }
    scores = ESPN.get_mlb_scores(day)
    assert scores.include?(expected), 'A known MLB final score cannot be found'
  end

  test 'mlb april 18th 2015 blue jays beat braves in extra innings' do
    day = Date.parse('Apr 18, 2015')
    expected = {
        league: 'mlb',
        game_date: day,
        home_team: 'tor',
        home_score: 6,
        away_team: 'atl',
        away_score: 5
    }
    scores = ESPN.get_mlb_scores(day)
    assert scores.include?(expected), 'A known MLB final score cannot be found'
  end
  
  test 'random mlb days' do
    random_days.each do |day|
      scores = ESPN.get_mlb_scores(day)
      assert all_names_present?(scores), "Error on #{day} for mlb"
    end
  end
  
end