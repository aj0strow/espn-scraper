require 'test_helper'

class NhlTest < EspnTest
  
  test 'nhl rangers beat bruins on valentines day' do
    day = Date.parse('Feb 14, 2012')
    expected = {
      league: 'nhl',
      game_date: day,
      home_team: 'bos',
      home_score: 0,
      away_team: 'nyr',
      away_score: 3,
      game_status: ESPN::GAME_STATUSES[:completed]
    }
    scores = ESPN.get_nhl_scores(day)
    assert_equal expected, scores.first
  end

  test 'nhl in progress score' do
    # we mock the response instead of visiting ESPN to ensure there's some in progress games
    game_statuses = [ESPN::GAME_STATUSES[:in_progress]]
    mock_path = File.join(File.dirname(__FILE__), '../mocks/live-nhl.html')
    mock_content = Nokogiri::HTML(File.read(mock_path))
    scores = ESPN::Scores.winner_loser_parse(mock_content, '2018-03-25', game_statuses)
    assert scores.any?
  end
  
  test 'random nhl dates' do
    random_days.each do |day|
      scores = ESPN.get_nhl_scores(day)
      assert all_names_present?(scores), "Error on #{day} for nhl"
    end
  end
    
end

