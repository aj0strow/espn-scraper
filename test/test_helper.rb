require 'test/unit'
require 'espn_scraper'

def test(test_name, &block)
  define_method("test_#{ test_name.gsub(/\s+/, '_') }", &block)
end

def all_names_present?(ary)
  ary.map do |obj|
    h, a = obj[:home_team], obj[:away_team]
    test = h.nil? || (h && h.empty?) || a.nil? || (a && a.empty?)
    puts h, a if test
    test
  end.count(true) == 0
end