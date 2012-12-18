require 'test_helper'

class EspnTest < Test::Unit::TestCase
	
	test 'espn is up' do
		assert responding?
		assert !down?
	end
	
	test 'paths are working' do
		assert_equal 'http://scores.espn.go.com', espn_url('scores')
		assert_equal 'http://espn.go.com/nba/teams', espn_url('nba', 'teams')
	end
	
end