# require 'test_helper'

# class DivisionsTest < EspnTest

#   test 'nfl afc north' do
#     nfl = ESPN.get_divisions['nfl']
#     assert nfl.include?({ name: 'AFC North', data_name: 'afc-north' })
#   end

#   test 'mlb al west' do
#     mlb = ESPN.get_divisions['mlb']
#     assert mlb.include?({ name: 'AL West', data_name: 'al-west' })
#   end

#   test 'nba central' do
#     nba = ESPN.get_divisions['nba']
#     assert nba.include?({ name: 'Central', data_name: 'central' })
#   end

#   test 'nhl pacific division' do
#     nhl = ESPN.get_divisions['nhl']
#     assert nhl.include?({ name: 'Pacific Division', data_name: 'pacific' })
#   end

#   test 'ncf conference usa' do
#     ncf = ESPN.get_divisions['ncf']
#     assert ncf.include?({ name: 'Conference USA', data_name: 'conference-usa' })
#   end

#   test 'ncb' do
#     ncb = ESPN.get_divisions['ncb']
#     assert ncb.include?({ name: 'ACC', data_name: 'acc' })
#   end

# end