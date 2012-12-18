module ESPN
  
  def self.get_scores(league, date)
    day = date.to_s.gsub(/[^\d]+/, '')
    doc = self.get 'scores', league, "scoreboard?date=#{ day }"
    scores = []
    doc.css('.mod-scorebox.final-state').each do |game|
      scores << game.css('.team').map do |team|
        [ team.at_css('.team-name a')['href'].split('/').last,
        team.at_css('.finalScore').content.to_i ]
      end
    end
    Hash[ *scores.flatten ]
  end
  
end