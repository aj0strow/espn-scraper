%w[ boilerplate teams scores schedules ].map do |file|
  require_relative "espn_scraper/#{ file }"
end
