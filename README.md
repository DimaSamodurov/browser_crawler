# Crawler

[![Build Status](https://travis-ci.org/DimaSamodurov/crawler.svg?branch=master)](https://travis-ci.org/DimaSamodurov/crawler)

Crawler is aimed to visit pages available on the site and extract useful information.

It can help maintaining e.g. lists of internal and external links,
creating sitemaps, visual testing using screenshots  
or prepare the list of urls for the more sophisticated tool like [Wraith](https://github.com/BBC-News/wraith). 

Browser based crawling is performed with the help of [Capybara](https://github.com/teamcapybara/capybara) and [Poltergeist](https://github.com/teampoltergeist/poltergeist).
Javascript is executed before page is analyzed allowing to crawl dynamic content.
Browser based crawling is essentially an alternative to Wraith's spider mode, 
which parses html and has limitations to static content by that. 

By default crawler visits the pages following the links extracted.
No button clicks performed other than during the optional authentication step.
Thus crawler does not perform any updates to the site and can be treated as noninvasive.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crawler', github: 'DimaSamodurov/crawler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crawler

## Usage

Without the authentication required:
```
crawl http://localhost:3000
```

With authentication, screenshots and limiting visited page number to 1:
```
crawl https://your.site.com/welcome -u username -p password -n 1 -s tmp/screenshots
```

Generate index from the captured screenshots. Index is saved to `tmp/screenshots/index.html`.
```
crawl -s tmp/screenshots
```

see additional options with:

```
crawl -h
```

When finished the crawling report will be saved to `crawl_report.yml` file by default.
You can specify the file path using command line options.

### Usage with Wraith

Crawler can be useful to update `paths:`  section of the wraith's configs.

Provided wraith config is placed to `wraith/configs/capture.yaml` file, do:
```
crawl https://your.site.com/welcome -c wraith/configs/capture.yaml 
```

Or if you have crawling report available, just use it without the URL to skip crawling:
``` 
bin/crawl -c wraith/configs/capture.yaml -r tmp/uat/crawl_report.yml
```

## Restrictions

Current version has the authentication process hardcoded: 
the path to login form and the field names used are specific to the project 
the crawler is extracted from.
Configuration may be added in a future version.

## Ideas for enhancements
It should be easy to crawl the site as part of the automated testing.
e.g. in order to verify the list of pages available on the site,
or in order to generate visual report (Wraith does it better).

### Integration with test frameworks

By integrating crawler into the application test suite 
it would be possible accessing pages and content not easily accessible on real site.
E.g. when performing data modifications.

By integrating into test suite it
would be possible to use all the tools/mocks/helpers/ created to simulate user behavior.
E.g. mock external request using e.g. VCR.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dimasamodurov/crawler.

## License 

MIT
