require 'test_helper'

class NcbTest < Test::Unit::TestCase
  
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
  

  test 'full year with no breaks' do
    puts "Checking an entire year for errors (will take a while)"
    (Date.parse('Feb 12, 2012')..Date.parse('Aug 1, 2012')).each do |day|
      scores = ESPN.get_college_basketball_scores(day)
      assert all_names_present?(scores), "Error on #{day} for college basketball"
    end
  end
  
end