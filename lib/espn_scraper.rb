%w[ boilerplate teams scores ].each do |file|
  require "espn_scraper/#{ file }"
end