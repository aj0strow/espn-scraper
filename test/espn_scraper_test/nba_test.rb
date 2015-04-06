require 'test_helper'

class NbaTest < EspnTest

  test 'nba december 25th celtics beat nets' do
    day = Date.parse('Dec 25, 2012')
    expected = {
      league: 'nba',
      game_date: day,
      home_team: 'bkn',
      home_score: 76,
      away_team: 'bos',
      away_score: 93
    }
    scores = ESPN.get_nba_scores(day)
    assert_equal expected, scores.first
  end

  test 'random nba days' do
    random_days.each do |day|
      scores = ESPN.get_nba_scores(day)
      assert all_names_present?(scores), "Error on #{day} for nba"
    end
  end

end