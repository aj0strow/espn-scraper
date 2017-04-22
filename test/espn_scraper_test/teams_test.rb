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
    assert divisions['al-west'].include?({ name: 'Seattle Mariners', data_name: 'sea' })
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
    assert_equal 7, divisions['central'].count
    assert_equal 8, divisions['atlantic'].count
    teams = divisions.values.flatten
    assert_equal 30, teams.map{ |h| h[:name] }.uniq.count
    assert_equal 30, teams.map{ |h| h[:data_name] }.uniq.count
    assert divisions['atlantic'].include?({ name: 'Montreal Canadiens', data_name: 'mtl' })
  end

  test 'scrape ncaa football teams' do
    divisions = ESPN.get_teams_in('college-football')
    assert_equal 25, divisions.count
    assert_equal 12, divisions['pac-12'].count

    assert divisions['conference-usa'].include?({ name: 'Rice Owls', data_name: '242' })
    assert divisions['meac'].include?({ name: 'Bethune-Cookman Wildcats', data_name: '2065' })
    assert divisions['northeast'].include?({ name: 'St Francis Red Flash', data_name: '2598' })
    assert divisions['swac'].include?({ name: 'Alabama State Hornets', data_name: '2011' })
  end

  test 'scrape ncaa basketball teams' do
    divisions = ESPN.get_teams_in('mens-college-basketball')
    assert_equal 32, divisions.count
    assert_equal 15, divisions['acc'].count
    assert_equal 10, divisions['patriot-league'].count

    assert divisions['southland'].include?({ name: 'Incarnate Word Cardinals', data_name: '2916' })
    assert divisions['atlantic-10'].include?({ name: "Saint Joe's Saint Joseph's Hawks", data_name: '2603' })
  end

  test 'scrape ncaa basketball conferences' do
    conferences = ESPN.get_conferences_in_ncb
    assert_equal 33, conferences.count
    assert conferences.include?({ name: 'Mountain West', data_name: '44' })
  end

end
