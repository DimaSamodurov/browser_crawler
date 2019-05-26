require 'spec_helper'
require 'rack'
require 'pry'
describe BrowserCrawler::EngineUtilities::CrawlManager do
  describe '#crawl' do
    let(:server) do
      fixture_path    = File.expand_path('spec/fixtures/static_site', Dir.getwd)
      app             = Rack::Builder.app do
        use Rack::Static, urls: { '/' => 'index.html' }, root: fixture_path
        run Rack::File.new(fixture_path)
      end

      Capybara.server = :webrick
      Capybara::Server.new(app).boot
    end

    let(:url) do
      "http://#{server.host}:#{server.port}"
    end

    it 'executes the cycle over array consists of links' do
      Capybara.current_session.quit
      Capybara.register_chrome_driver(:cuprite_chrome,
                                      options: { window_size: [1024, 768] })

      Capybara.run_server             = false
      Capybara.default_driver         = :cuprite_chrome
      # a workaround to extracting data from inactive tabs, dialogs, etc.
      Capybara.ignore_hidden_elements = false

      report_store = BrowserCrawler::Reports::Store.new

      crawl_manager = described_class.new(report_store: report_store)

      crawl_manager.crawl(target_url: url,
                          capybara_session: Capybara.current_session)

      extracted_links = report_store.pages[url][:extracted_links]

      expect(extracted_links[0]).to match /page1.html/
      expect(report_store.visited_pages.size).to eq(10)
    end

    it 'raises error if target url is invalid' do
      crawl_manager = described_class.new(report_store: nil)

      expect do
        crawl_manager.crawl(target_url: 'unrecognized_link',
                            capybara_session: nil)
      end.to raise_error(URI::InvalidURIError)
    end
  end

  describe '#link_valid?' do
    it 'returns true if a link is valid' do
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      crawl_manager = described_class.new(report_store: report_store,
                                          max_pages: 0,
                                          deep_visit: false)

      expect(crawl_manager.link_valid?(link_inspector)).to eq(true)
    end

    it 'returns false if a link refers to external resource' do
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: 'external.resource'
      )
      report_store = BrowserCrawler::Reports::Store.new

      crawl_manager = described_class.new(report_store: report_store,
                                          max_pages: 0,
                                          deep_visit: false)

      expect(crawl_manager.link_valid?(link_inspector)).to eq(false)
    end

    it 'returns false if a link refers to the visited resource' do
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store
                     .new(pages: { 'https://127.0.0.1/home' => {} })

      crawl_manager = described_class.new(report_store: report_store,
                                          max_pages: 0,
                                          deep_visit: false)

      expect(crawl_manager.link_valid?(link_inspector)).to eq(false)
    end

    it 'returns true if deep_visit value is true' do
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: 'external.resource'
      )
      report_store = BrowserCrawler::Reports::Store.new

      crawl_manager = described_class.new(report_store: report_store,
                                          max_pages: 0,
                                          deep_visit: true)

      expect(crawl_manager.link_valid?(link_inspector)).to eq(true)
    end
  end
end
