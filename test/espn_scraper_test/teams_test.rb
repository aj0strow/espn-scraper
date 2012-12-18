require 'test_helper'

class TeamsTest < Test::Unit::TestCase
	
	test 'scrape nba teams' do
		assert ESPN.get_teams_in('nba')['southeast'].include?({ name: 'Miami Heat' })
	end
	
	test 'scrape nfl teams' do
		assert ESPN.get_teams_in('nfl')['nfc-west'].include?({ name: 'Seattle Seahawks' })
	end
	
	test 'scrape mlb teams' do
		assert ESPN.get_teams_in('mlb')['al-west'].include?({ name: 'Seattle Mariners' })
	end
	
	test 'scrape nhl teams' do
		assert ESPN.get_teams_in('nhl')['central-division'].include?({ name: 'Detroit Red Wings' })
	end
	
	test 'scrape ncaa football teams' do
		assert ESPN.get_teams_in('college-football')['pac-12'].include?({ name: 'Washington' })
	end
	
	test 'scrape ncaa basketball teams' do
		assert ESPN.get_teams_in('mens-college-basketball')['acc'].include?({ name: 'Duke' })
	end
	
end