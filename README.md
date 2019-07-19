# Browser Crawler

[![Build Status](https://travis-ci.org/DimaSamodurov/browser_crawler.svg?branch=master)](https://travis-ci.org/DimaSamodurov/browser_crawler)

Browser Crawler is aimed to visit pages available on the site and extract useful information.

It can help maintaining e.g. lists of internal and external links,
creating sitemaps, visual testing using screenshots  
or prepare the list of urls for the more sophisticated tool like [Wraith](https://github.com/BBC-News/wraith). 

Browser based crawling is performed with the help of [Capybara](https://github.com/teamcapybara/capybara) and Chrome.
Javascript is executed before page is analyzed allowing to crawl dynamic content.
Browser based crawling is essentially an alternative to Wraith's spider mode, 
which parses only server side rendered html. 

By default crawler visits pages following the links extracted.
No button clicks performed other than during the optional authentication step.
Thus crawler does not perform any updates to the site and can be treated as noninvasive.

## Table of contents
- [Installation](#installation)
- [Usage from command line](#usage-from-command-line)
- [Usage with scripting](#usage-with-scripting)
    - [Callback methods](#callback-methods)
        - [Callback methods Before/After crawling](#callback-methods-before-or-after-crawling)
        - [Callback methods Before/After for each crawling page](#callback-methods-before-or-after-for-each-page)
        - [Callback method is recorded unvisited links](#callback-method-unvisited-links)
        - [Callback method is changed page scan rules](#callback-method-page-scan-rules)
        - [Setup folder to save report file](#setup-folder-for-report)
        - [Save report to yaml file](#save-report-to-yaml)
        - [Save report to csv file](#save-report-to-csv)
    - [Usage with Wraith](#usage-with-wraith)
- [Restrictions](#restrictions)
- [Ideas for enhancements](#ideas-for-enchancements)
   - [Integration with test frameworks](#integration-with-test-frameworks)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## <a name="installation"></a> Installation

Add this line to your application's Gemfile:

```ruby
gem 'crawler', github: 'DimaSamodurov/crawler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install browser_crawler

## <a name="usage-from-command-line"></a> Usage from command line

Without the authentication required:
```
crawl http://localhost:3000
```

With authentication, screenshots and limiting visited page number to 1:
```
crawl https://your.site.com/welcome -u username -p password -n 1 -s tmp/screenshots
# or
export username=dima
export password=secret
#... 
crawl https://your.site.com/welcome -n 1 -s tmp/screenshots
```

Generate index from the captured screenshots. Index is saved to `tmp/screenshots/index.html`.
```
bin/crawl -s tmp/screenshots
```

see additional options with:

```
bin/crawl -h
```

When finished the crawling report will be saved to `tmp/crawl_report.yml` file by default.
You can specify the file path using command line options.

## <a name="usage-with-scripting"></a> Usage with scripting

Below pointed an example script which configures the crawler and targets on the `github.com` site
and after that records the result report as yaml file.
```
crawler = BrowserCrawler::Engine.new({
    browser_options: {
        headless: true,
        window_size: [1200, 1600],
        timeout: 60,
        browser_options: { 'no-sandbox': nil }
    },
    max_pages: 10,
    deep_visit: true 
})

crawler.extract_links(url: 'https://github.com')
crawler.report_save
```

This gem use external dependency a `cuprite`. The `cuprite` allows working with browser without intermediaries (chrome-driver).
`browser_options` responsible for configuration the chrome headless browser though the `cuprite`.

* `max_pages` - an additional option to allow to set amount of pages for crawling. 
By default it equals `nil` and allows the crawler is browsing all pages within a certain domain.
* `deep_visit` - a mode of the crawler when the crawler checks external resources without collecting links from them.


### <a name="callback-methods"></a> Callback methods

All of them you can use with Capybara DSL.

#### <a name="callback-methods-before-or-after-crawling"></a> Callback methods Before/After crawling
```
crawler = BrowserCrawler::Engine.new()

# scroll down page before scan.
crawler.before do
  page.execute_script 'window.scrollBy(0,10000)' 
end

crawler.after do
   page.body  
end 

crawler.extract_links(url: 'https://github.com')
```

#### <a name="callback-methods-before-or-after-for-each-page"></a> Callback methods Before/After for each crawling page
```
crawler = BrowserCrawler::Engine.new()

# scroll down page before scan.
crawler.before type: :each do
    page.execute_script 'window.scrollBy(0,10000)' 
end

crawler.after type: :each do
   page.body
end 

crawler.extract_links(url: 'https://github.com')
```

#### <a name="callback-method-unvisited-links"></a> Callback method is recorded unvisited links
Default behavior: by default crawler is sent all links from page to an unvisited_links array 
and after that browses each of them. This callback allows to change this behavior.
```
crawler = BrowserCrawler::Engine.new()

# scan_result consists of array with links from scaned page.
crawler.unvisited_links do
  @page_inspector.scan_result   
end

crawler.extract_links(url: 'https://github.com')
```

Changed behavior: change default behavior so that crawler browses only links which consist of `/best-links`.
```
crawler = BrowserCrawler::Engine.new()

crawler.unvisited_links do
  @page_inspector.scan_result.select { |link| link.include?('/best-links') }   
end

crawler.extract_links(url: 'https://github.com')
```

#### <a name="callback-method-page-scan-rules"></a> Callback method is changed page scan rules
Default behavior: by default crawler get all links from page and move to one to another.
```
crawler = BrowserCrawler::Engine.new()

crawler.change_page_scan_rules do
  page.all('a').map { |a| a['href'] }   
end

crawler.extract_links(url: 'https://github.com')
```

Changed behavior: change default behavior so that crawler get only links to have selector `paginations`. 
```
crawler = BrowserCrawler::Engine.new()

crawler.change_page_scan_rules do
  if URI.parse(page.current_url).to_s.include?('/help/')
    page.all('a.paginations') { |a| a['href'] }
  else
    []  
  end 
end

crawler.extract_links(url: 'https://github.com')
```

#### <a name="setup-folder-for-report"></a> Setup folder to save report file
```
crawler = BrowserCrawler::Engine.new()
crawler.extract_links(url: 'https://github.com')

crawler.report_save(folder_path: './reports/')
```
If the folder doesn't exist, `BrowserCrawler` create the folder for report.

#### <a name="save-report-to-yaml"></a> Save report to yaml file
```
crawler = BrowserCrawler::Engine.new()
crawler.extract_links(url: 'https://github.com')

crawler.report_save(type: :yaml)
```

#### <a name="save-report-to-csv"></a> Save report to csv file
```
crawler = BrowserCrawler::Engine.new()
crawler.extract_links(url: 'https://github.com')

crawler.report_save(type: :csv)
```

### <a name="usage-with-wraith"></a> Usage with Wraith

Browser Crawler can be useful to update `paths:`  section of the wraith's configs.

Provided wraith config is placed to `wraith/configs/capture.yaml` file, do:
```
crawl https://your.site.com/welcome -c wraith/configs/capture.yaml 
```

Or if you have crawling report available, just use it without the URL to skip crawling:
``` 
bin/crawl -c tmp/wraith_config.yml -r tmp/crawl_report.yml
```

## <a name="restrictions"></a> Restrictions

Current version has the authentication process hardcoded: 
the path to login form and the field names used are specific to the project 
the crawler is extracted from.
Configuration may be added in a future version.

## <a name="ideas-for-enchancements"></a> Ideas for enhancements
It should be easy to crawl the site as part of the automated testing.
e.g. in order to verify the list of pages available on the site,
or in order to generate visual report (Wraith does it better).

### <a name="integration-with-test-frameworks"></a> Integration with test frameworks

By integrating browser_crawler into the application test suite 
it would be possible accessing pages and content not easily accessible on real site.
E.g. when performing data modifications.

By integrating into test suite it
would be possible to use all the tools/mocks/helpers/ created to simulate user behavior.
E.g. mock external request using e.g. VCR.


## <a name="development"></a> Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## <a name="contributing"></a> Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dimasamodurov/browser_crawler.

## <a name="license"></a> License 

MIT
