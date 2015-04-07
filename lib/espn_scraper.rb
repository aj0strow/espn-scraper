%w[ boilerplate teams scores schedules ].each do |file|
  require "espn_scraper/#{ file }"
end
