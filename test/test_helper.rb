require 'test/unit'
require 'espn_scraper'

def test(test_name, &block)
	define_method("test_#{test_name}", &block)
end
