require 'test_helper'

class TeamsTest < EspnTest

  test 'scrape nfl teams' do
    divisions = ESPN.get_teams_in('nfl')
    assert_equal 8, divisions.count
    divisions.each do |name, teams|
      assert_equal 4, teams.count
    end
    teams = divisions.values.flatten
    assert_equal 32, teams.map{ |h| h[:name] }.uniq.count
    assert_equal 32, teams.map{ |h| h[:data_name] }.uniq.count
    assert divisions['nfc-west'].include?({ name: 'Seattle Seahawks', data_name: 'sea' })
  end

  test 'scrape mlb teams' do
    divisions = ESPN.get_teams_in('mlb')
    assert_equal 6, divisions.count
    divisions.each do |name, teams|
      assert_equal 5, teams.count
    end
    teams = divisions.values.flatten
    assert_equal 30, teams.map{ |h| h[:name] }.uniq.count
    assert_equal 30, teams.map{ |h| h[:data_name] }.uniq.count
    assert divisions['american-league-west'].include?({ name: 'Seattle Mariners', data_name: 'sea' })
  end

  test 'scrape nba teams' do
    divisions = ESPN.get_teams_in('nba')
    assert_equal 6, divisions.count
    divisions.each do |name, teams|
      assert_equal 5, teams.count
    end
    teams = divisions.values.flatten
    assert_equal 30, teams.map{ |h| h[:name] }.uniq.count
    assert_equal 30, teams.map{ |h| h[:data_name] }.uniq.count
    assert divisions['atlantic'].include?({ name: 'Toronto Raptors', data_name: 'tor' })
  end

  test 'scrape nhl teams' do
    divisions = ESPN.get_teams_in('nhl')
    assert_equal 4, divisions.count
    assert_equal 8, divisions['central'].count
    assert_equal 8, divisions['atlantic'].count
    teams = divisions.values.flatten
    assert_equal 32, teams.map{ |h| h[:name] }.uniq.count
    assert_equal 32, teams.map{ |h| h[:data_name] }.uniq.count
    assert divisions['atlantic'].include?({ name: 'Montreal Canadiens', data_name: 'mtl' })
  end

  test 'scrape ncaa football teams' do
    divisions = ESPN.get_teams_in('college-football')
    assert_equal 11, divisions.count
    assert_equal 2, divisions['pac-12'].count

    assert divisions['conference-usa'].include?({ name: 'Liberty Flames', data_name: '2335' })
    assert divisions['mid-american'].include?({ name: 'Ball State Cardinals', data_name: '2050' })
    assert divisions['big-ten'].include?({ name: 'Penn State Nittany Lions', data_name: '213' })
    assert divisions['sun-belt'].include?({ name: 'South Alabama Jaguars', data_name: '6' })
  end

  test 'scrape ncaa basketball teams' do
    divisions = ESPN.get_teams_in('mens-college-basketball')
    assert_equal 31, divisions.count
    assert_equal 18, divisions['acc'].count
    assert_equal 10, divisions['patriot-league'].count

    assert divisions['southland'].include?({ name: 'Incarnate Word Cardinals', data_name: '2916' })
    assert divisions['atlantic-10'].include?({ name: "Saint Joseph's Hawks Saint Josephs Hawks", data_name: '2603' })
  end

  test 'scrape ncaa basketball conferences' do
    conferences = ESPN.get_conferences_in_ncb
    assert_equal 32, conferences.count
    assert conferences.include?({ name: 'Mountain West', data_name: '44' })
  end

end
