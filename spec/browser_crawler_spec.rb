require 'spec_helper'
require 'rack'

describe BrowserCrawler do
  it 'has a version number' do
    expect(BrowserCrawler::VERSION).not_to be nil
  end

  let(:server) do
    fixture_path = File.expand_path('fixtures/static_site', __dir__)
    app = Rack::Builder.app do
      use Rack::Static, urls: {'/' => 'index.html'}, root: fixture_path
      run Rack::File.new(fixture_path)
    end
    Capybara.server = :webrick
    Capybara::Server.new(app).boot
  end

  let(:url) do
    "http://#{server.host}:#{server.port}/"
  end

  it 'starts crawling with the path provided in the url' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}page2.html")
    expect(crawler.visited_pages.first).to eql '/page2.html'
  end

  it 'extracts links from the page with options only_path' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: url)

    extracted_links = crawler.report_store.pages['/'][:extracted_links]

    expect(extracted_links[0]).to match /page1.html/
    expect(extracted_links[1]).to match /page2.html/
    expect(extracted_links[2]).to match /page3.html/
  end

  it 'extracts links from the page with' do
    crawler = BrowserCrawler::Engine.new(max_pages: 1)
    crawler.extract_links(url: url, only_path: false)

    url, page_report = crawler.report_store.pages.first
    extracted_links = page_report[:extracted_links]

    expect(extracted_links[0]).to match /page1.html/
    expect(extracted_links[0]).to match /http:\/\/127\.0\.0\.1/
    expect(url).to match /http:\/\/127\.0\.0\.1/
  end

  it 'visits internal pages' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: url)
    internal_pages = %w[/ /page1.html /page11.html /page12.html /page2.html /page21.html]
    expect(internal_pages - crawler.report_store.visited_pages).to be_empty
  end

  describe 'with max_pages option specified' do
    it 'extracts visits not more than specified number of pages' do
      crawler = BrowserCrawler::Engine.new(max_pages: 2)
      crawler.extract_links(url: url)
      expect(crawler.report_store.visited_pages.count).to eql 2
    end
  end

  it 'skips visit to the page if an url is not recognized' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}page4.html")

    expect(crawler.visited_pages).to eql ['/page4.html']
    unrecognized_links = crawler.report_store.unrecognized_links
    expect(unrecognized_links.include?('javascript://:')).to be true
    expect(unrecognized_links.include?('mailto:example@com')).to be true
  end

  it 'excludes empty links from report' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}page5.html")

    extracted_links = crawler.report_store
                             .pages['/page5.html'][:extracted_links]
    expect(extracted_links).to eql []
  end

  context 'change Capybara driver' do
    let(:app) do
      fixture_path = File.expand_path('fixtures/static_site', __dir__)
      Rack::Builder.app do
        use Rack::Static, urls: {'/' => 'index.html'}, root: fixture_path
        run Rack::File.new(fixture_path)
      end
    end

    it 'executes javascript before extracts links from the page' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}/"

      javascript = %{
                      window.addEventListener("load", function(){
                        var e = document.body;
                        e.innerHTML = '';
                      });
                    }

      crawler = BrowserCrawler::Engine.new(max_pages: 1)
      crawler.js_before_run(javascript: javascript)
      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages['/'][:extracted_links]

      expect(extracted_links).to eq([])
    end

    it 'overwrites before_crawling callback method and executes it' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}/"

      crawler = BrowserCrawler::Engine.new(max_pages: 1)

      crawler.overwrite_callback(method: :before_crawling) do
        @report_store.record_page_visit(page: '/before_crawling', extracted_links: ['link1'])
      end

      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages['/before_crawling'][:extracted_links]

      expect(extracted_links).to eq(['link1'])
    end


    it 'overwrites after_crawling callback method and executes it' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}/"

      crawler = BrowserCrawler::Engine.new(max_pages: 1)

      crawler.overwrite_callback(method: :after_crawling) do
        @report_store.record_page_visit(page: '/after_crawling', extracted_links: ['link1'])
      end

      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages['/after_crawling'][:extracted_links]

      expect(extracted_links).to eq(['link1'])
    end
  end
end
