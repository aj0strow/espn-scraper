require 'rake/testtask'

task :load_path do
  %w(lib test).each do |path|
    $LOAD_PATH.unshift File.expand_path("../#{path}", __FILE__)
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/espn_scraper_test/scores_test.rb']
  t.verbose = true
end

task default: :test