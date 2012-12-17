require 'test_helper'

class EspnTest < Test::Unit::TestCase
	
	test 'espn is up' do
		assert responding?
		assert !down?
	end
	
end