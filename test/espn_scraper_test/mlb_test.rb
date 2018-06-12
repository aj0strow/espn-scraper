require 'test_helper'

class MlbTest < EspnTest

  test 'mlb august 13th 2012 yankees beat rangers' do
    starts_at = DateTime.parse('2012-08-13T23:00:00+00:00')
    expected = {
      league: 'mlb',
      game_date: starts_at,
      home_team: 'nyy',
      home_score: 8,
      away_team: 'tex',
      away_score: 2,
      season_type: ESPN::SEASONS[:regular_season],
      game_status: ESPN::GAME_STATUSES[:completed]
    }
    scores = ESPN.get_mlb_scores(starts_at.to_date)
    assert scores.include?(expected), 'A known MLB final score cannot be found'
  end

  test 'mlb april 18th 2015 blue jays beat braves in extra innings' do
    starts_at = DateTime.parse('2015-04-18T17:07:00+00:00')
    expected = {
        league: 'mlb',
        game_date: starts_at,
        home_team: 'tor',
        home_score: 6,
        away_team: 'atl',
        away_score: 5,
        season_type: ESPN::SEASONS[:regular_season],
        game_status: ESPN::GAME_STATUSES[:completed]
    }
    scores = ESPN.get_mlb_scores(starts_at.to_date)
    assert scores.include?(expected), 'A known MLB final score cannot be found'
  end

  test 'mlb sept 5th 2014 suspended game pittsburgh pirates at chicago cubs' do
    scores = ESPN.get_mlb_scores(Date.parse('2014-09-05'))
    home_teams = scores.each { |s| s['home_team'] }
    assert !home_teams.include?('chc'), 'A known suspended game was unexpectedly found'
  end

  test 'random mlb days' do
    random_days.each do |day|
      scores = ESPN.get_mlb_scores(day)
      assert all_names_present?(scores), "Error on #{day} for mlb"
    end
  end

  test 'in progress mlb scores' do
    season_types = [ESPN::SEASONS[:preseason]]
    game_statuses = [ESPN::GAME_STATUSES[:in_progress]]
    # we mock the response instead of visiting ESPN to ensure there's some in progress games
    mock_path = File.join(File.dirname(__FILE__), '../mocks/live-mlb.html')
    mock_content = Nokogiri::HTML(File.read(mock_path))
    scores = ESPN::Scores.home_away_parse(mock_content, '2018-03-22', season_types, game_statuses)
    assert_equal ESPN::GAME_STATUSES[:in_progress], scores.first[:game_status]
  end

  test 'scheduled mlb scores' do
    # we mock the response instead of visiting ESPN to ensure there's some in progress games
    game_statuses = [ESPN::GAME_STATUSES[:scheduled]]
    mock_path = File.join(File.dirname(__FILE__), '../mocks/scheduled-mlb.html')
    mock_content = Nokogiri::HTML(File.read(mock_path))
    scores = ESPN::Scores.home_away_parse(mock_content, '2018-06-12', nil, game_statuses)
    assert scores.any?
  end

end

