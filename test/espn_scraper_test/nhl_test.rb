require 'test_helper'

class NhlTest < EspnTest

  test 'nhl rangers beat bruins on valentines day' do
    day = Date.parse('Feb 14, 2012')
    expected = {
      league: 'nhl',
      game_date: day,
      home_team: 'bos',
      home_score: 0,
      away_team: 'nyr',
      away_score: 3
    }
    scores = ESPN.get_nhl_scores(day)
    assert_equal expected, scores.first
  end

  test 'random nhl dates' do
    random_days.each do |day|
      scores = ESPN.get_nhl_scores(day)
      assert all_names_present?(scores), "Error on #{day} for nhl"
    end
  end

end