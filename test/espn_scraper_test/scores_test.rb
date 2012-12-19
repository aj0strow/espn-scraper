require 'test_helper'

class ScoresTest < Test::Unit::TestCase
  
  test 'cavaliers had 106 points scored on them february 11th 2010' do
    day = Date.parse 'Feb 11, 2010'
    scores = ESPN.get_scores('nba', day)
    assert_equal 'cleveland-cavaliers', scores.first['home_team']
    assert_equal 106, scores.first['away_score']
  end

  test 'oakland athletics scored 2 runs at home on may 9th 2012' do
    day = Date.parse 'May 9, 2012'
    scores = ESPN.get_scores('mlb', day)
    assert_equal 'oakland-athletics', scores.first['home_team']
    assert_equal 2, scores.first['home_score']
  end
  
  test 'toronto lost in washington on december 9th 2011' do
    day = Date.parse 'Dec 9, 2011'
    scores = ESPN.get_scores('nhl', day)
    assert_equal 'toronto-maple-leafs', scores.first['away_team']
    assert_equal 'washington-capitals', scores.first['home_team']
    assert scores.first['away_score'] < scores.first['home_score']
  end
    
  test 'ravens scored 23 points in week 4, 2012' do
    week, year = 4, 2012
    scores = ESPN.get_scores('nfl', year, week)
    assert_equal 'ravens', scores.first['home_team']
    assert_equal 23, scores.first['home_score']
  end
    
end