require 'test_helper'

class MlbTest < EspnTest
  
  test 'mlb august 13th yankees beat rangers' do
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
    assert_equal expected, scores.first
  end
  
  test 'random mlb days' do
    random_days.each do |day|
      scores = ESPN.get_mlb_scores(day)
      assert all_names_present?(scores), "Error on #{day} for mlb"
    end
  end
  
end