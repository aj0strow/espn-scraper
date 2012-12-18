require 'test_helper'

class TeamsTest < Test::Unit::TestCase
	
	test 'scrape nba teams' do
		assert get_teams_in('nba')['southeast'].include?({ name: 'Miami Heat', knickname: 'heat' })
	end
	
end