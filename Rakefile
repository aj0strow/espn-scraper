require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/espn_scraper_test/*_test.rb']
  t.verbose = true
end

task default: :test