%w[ boilerplate teams scores schedules ].each do |file|
  require_relative "espn_scraper/#{ file }"
end
