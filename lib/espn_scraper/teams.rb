module ESPN

  def self.get_teams_in(league)
  	doc = self.get(league, 'teams')
  	divisions = {}
	
  	doc.css('.mod-teams-list-medium').each do |division|
  		key = division.at_css('.mod-header h4 text()').content.dasherize		
  		divisions[key] = division.css('.mod-content li').map do |team|
  		  { name: team.at_css('h5 a.bi').content }
  		end
  	end
  	divisions
  end

end