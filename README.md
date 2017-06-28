# ESPN Scraper

ESPN Scraper is a simple gem for scraping teams and scores from `ESPN`'s website. Please note that `ESPN` is not involved with this gem or me in any way. I chose `ESPN` because it is a leader in sports statistics and has a robust website.

```ruby
ESPN.responding?
# => true
```

Lets begin...

#### Supported leagues

The gem only supports the following leagues:

```ruby
ESPN.leagues
# => [ "nfl", "mlb", "nba", "nhl", "ncf", "ncb" ]
```

Which are the NFL, MLB, NBA, NHL, NCAA D1 Football, NCAA D1 Men's Basketball respectively.

#### Scrape Divisions

You can get all the divisions in each league.

```ruby
ESPN.get_divisions
# => {
#   "nfl" => [
#     { :name => "NFC East", :data_name => "nfc-east" },
#     { :name => "NFC West", :data_name => "nfc-west" },
#     ...
#   ],
#   "mlb" => ...
# }
```

#### Scrape Conferences (NCAA D1 Men's Basketball only)

You can get all the conferences in NCAA D1 Men's Basketball.

```ruby
ESPN.get_conferences_in_ncb
# => [{:name=>"America East", :data_name=>"1"},
#      {:name=>"American", :data_name=>"62"},
#      ...
#      ]
```

#### Scrape teams

You can get the teams in each league by acronym. It returns a hash of each division with an array of hashes for each team in the division.

```ruby
ESPN.get_teams_in('nba')
# => {
#   "atlantic"=> [
#     { :name => "Boston Celtics", :data_name => "bos" },
#     { :name => "Brooklyn Nets", :data_name => "bkn" },
#     { :name => "New York Knicks", :data_name => "ny" },
#     { :name => "Philadelphia 76ers", :data_name => "phi" },
#     { :name => "Toronto Raptors", :data_name => "tor" }
#   ]
#   "pacific" => ...
# }
```

#### Scraping scores

All score requests return an array of hashes. Here's an example NFL score hash:

```ruby
{
  league: 'nfl',
  game_date: #<DateTime: 2012-10-25>,
  home_team: 'min',
  home_score: 17,
  away_team: 'tb',
  away_score: 36
}
```

You'll notice the teams are identified with the same `:data_name` from a `ESPN.get_teams_in` request. One issue with scraping scores is that football goes by year and week, and baseball, basketball, hockey go by date.

###### weekly (football)

Pattern is `ESPN.get_<league>_scores(year, week)`. This is for `nfl` and `ncf`:

```ruby
ESPN.get_nfl_scores(2012, 8)
ESPN.get_ncf_scores(2011, 3)
```

###### daily (baseball, basketball, hockey)

Pattern is `ESPN.get_<league>_scores(date)`. This is for `mlb`, `nba`, `nhl`, `ncb`:

```ruby
ESPN.get_mlb_scores( Date.parse('Aug 13, 2012') )
ESPN.get_nba_scores( Date.parse('Dec 25, 2011') )
ESPN.get_nhl_scores( Date.parse('Feb 14, 2009') )
ESPN.get_ncb_scores( Date.parse('Mar 15, 2012') )
```

## Installing

Add the gem to your `Gemfile`

```ruby
gem 'espn_scraper', git: 'git://github.com/aj0strow/espn-scraper.git'
# or
gem 'espn_scraper', github: 'aj0strow/espn-scraper'
```

..and then require it. I personally use it in rake tasks of a Rails app.

```ruby
require 'espn_scraper'
```

## Contributing

Please report back if something breaks on you!

Also please let me know if any of the data names get outdated. For instance a bunch of NFL data names were recently changed. You can make fixes temporarily with the following:

```ruby
ESPN::DATA_NAME_FIXES['nfl']['gnb'] = 'gb'
```

Running tests:
```
rake test
```

Re-building the gem and installing locally:
```
gem build espn_scraper.gemspec
gem uninstall espn_scraper
gem install espn_scraper-x.x.x.gem
```

Future plans:
- Get start and end dates of a season

### Thank You

* Dan Madere ([dgmdan](https://github.com/dgmdan))

---

**MIT License**
