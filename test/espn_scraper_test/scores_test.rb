require 'test_helper'

class ScoresTest < Test::Unit::TestCase
  
  # test 'cavaliers had 106 points scored on them february 11th 2010' do
  #     day = Date.parse 'Feb 11, 2010'
  #     score = ESPN.get_scores('nba', day).first
  #     assert_equal 'cleveland-cavaliers', score['home_team']
  #     assert_equal 106, score['away_score']
  #   end
  
  test 'nba Dec 26th 2011 doesnt blow up' do
    day = Date.parse '26 Dec 2011'
    assert ESPN.get_scores('nba', day)
  end

  test 'oakland athletics scored 2 runs at home on may 9th 2012' do
    day = Date.parse 'May 9, 2012'
    score = ESPN.get_scores('mlb', day).first
    assert_equal 'oakland-athletics', score['home_team']
    assert_equal 2, score['home_score']
  end
      
  test 'toronto lost in washington on december 9th 2011' do
    day = Date.parse 'Dec 9, 2011'
    score = ESPN.get_scores('nhl', day).first
    assert_equal 'toronto-maple-leafs', score['away_team']
    assert_equal 'washington-capitals', score['home_team']
    assert score['away_score'] < score['home_score']
  end
        
  test 'ravens scored 23 points in week 4, 2012' do
    week, year = 4, 2012
    score = ESPN.get_scores('nfl', year, week).first
    assert_equal 'ravens', score['home_team']
    assert_equal 23, score['home_score']
  end
    
end