require 'test_helper'

class BoilerplateTest < EspnTest

  test 'espn is up' do
    assert ESPN.responding?
    assert !ESPN.down?
  end

  test 'paths are working' do
    assert_equal 'http://www.espn.com', ESPN.url('scores')
    assert_equal 'http://www.espn.com/nba/teams', ESPN.url('nba', 'teams')
  end

  test 'error message works' do
    assert_raises(ArgumentError) do
      ESPN.get('bad-api-keyword')
    end
  end

  test 'get pages is working' do
    assert ESPN.get('scores')
  end

  test 'dasherize strings' do
    assert_equal 'string-is-dashed', ESPN.send(:dasherize, 'String is dashed')
  end

  test 'leagues' do
    leagues = 'nfl mlb nba nhl ncf ncb'.split
    assert_equal leagues, ESPN.leagues
  end

end
