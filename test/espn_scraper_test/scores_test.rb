require 'test_helper'

class ScoresTest < Test::Unit::TestCase
  
  test 'orlando magic had 106 poings on february 11th 2010' do
    day = Date.parse 'Feb 11, 2010'
    assert_equal 106, ESPN.get_scores('nba', day)['orlando-magic']
  end
  
  
  
end