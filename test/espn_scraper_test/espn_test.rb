require 'test_helper'

class EspnTest < Test::Unit::TestCase
	
  test 'espn is up' do
    assert ESPN.responding?
    assert !ESPN.down?
  end
	
  test 'paths are working' do
    assert_equal 'http://scores.espn.go.com', ESPN.url('scores')
    assert_equal 'http://espn.go.com/nba/teams', ESPN.url('nba', 'teams')
  end
	
  test 'get pages is working' do
    assert ESPN.get('scores')
  end
	
  test 'add dasherize to string' do
    assert_equal 'string-is-dashed', 'String is dashed'.dasherize
  end
  
  test 'leagues' do
    leagues = 'nfl mlb nba nhl ncf ncb'.split
    assert_equal leagues, ESPN.leagues
  end

end