require 'spec_helper'
require 'rack'

describe BrowserCrawler do
  it 'has a version number' do
    expect(BrowserCrawler::VERSION).not_to be nil
  end

  let(:server) do
    fixture_path    = File.expand_path('fixtures/static_site', __dir__)
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

  it 'starts crawling with the path provided in the url' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}/page2.html")
    expect(crawler.visited_pages.first).to eql "#{url}/page2.html"
  end

  it 'extracts links from the page' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: url)

    extracted_links = crawler.report_store.pages[url][:extracted_links]

    expect(extracted_links[0]).to match /page1.html/
    expect(extracted_links[1]).to match /page2.html/
    expect(extracted_links[2]).to match /page3.html/
  end

  it 'visits internal pages' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: url)

    expect(crawler.report_store.visited_pages.size).to eq(10)
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
    crawler.extract_links(url: "#{url}/page4.html")

    expect(crawler.visited_pages).to eql ["#{url}/page4.html"]
    unrecognized_links = crawler.report_store.unrecognized_links
    expect(unrecognized_links.include?('javascript://:')).to be true
    expect(unrecognized_links.include?('mailto:example@com')).to be true
  end

  it 'excludes empty links from report' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}/page5.html")

    extracted_links = crawler.report_store
                        .pages["#{url}/page5.html"][:extracted_links]
    expect(extracted_links).to eql []
  end

  it 'checks that screenshot was saved' do
    Dir.mktmpdir do |folder_path|
      crawler = BrowserCrawler::Engine.new(screenshots_options: {
        save_screenshots_to: folder_path
      })
      crawler.extract_links(url: "#{url}/page5.html")

      expect(Dir["#{folder_path}/*/*"][0]).to match(/page5\.html\.png/)
      report_screenshot = crawler.report_store
                            .pages["#{url}/page5.html"][:screenshot]
      expect(report_screenshot).to match(/page5\.html\.png/)
    end
  end

  it 'checks that store consists of full information about visited pages' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}/page6.html")

    expect(crawler.report_store.pages["#{url}/page9999.html"])
      .to eq(
            {
              code:            404,
              error:           nil,
              external:        false,
              extracted_links: [],
              screenshot:      nil
            }
          )
  end

  it 'checks that information about external urls were added to store' do
    crawler = BrowserCrawler::Engine.new(deep_visit: true)

    crawler.extract_links(url: "#{url}/page7.html")

    expect(crawler.report_store.pages)
      .to eq(
            { "#{url}/page7.html"    => {
              :code            => 200,
              :error           => nil,
              :external        => false,
              :extracted_links => ['http://localhost:12345/page9999.html'],
              :screenshot      => nil
            },
              'http://localhost:12345/page9999.html' => {
                :code            => 200,
                :error           => nil,
                :external        => true,
                :extracted_links => [],
                :screenshot      => nil
              }
            }
          )
  end

  it 'checks that information about external urls were not added to store' do
    crawler = BrowserCrawler::Engine.new(deep_visit: false)

    crawler.extract_links(url: "#{url}/page7.html")

    expect(crawler.report_store.pages)
      .to eq(
            {
              "#{url}/page7.html" => {
                :code            => 200,
                :error           => nil,
                :external        => false,
                :extracted_links => ['http://localhost:12345/page9999.html'],
                :screenshot      => nil
              }
            }
          )
  end

  it 'checks that crawler does not scan link twice or more times' do
    crawler = BrowserCrawler::Engine.new
    crawler.extract_links(url: "#{url}/page8.html")

    expect(crawler.report_store.pages.size).to eq(2)
  end

  context 'change Capybara driver' do
    let(:app) do
      fixture_path = File.expand_path('fixtures/static_site', __dir__)
      Rack::Builder.app do
        use Rack::Static, urls: { '/' => 'index.html' }, root: fixture_path
        run Rack::File.new(fixture_path)
      end
    end

    it 'executes javascript before extracts links from the page' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}"

      javascript = %{
                      window.addEventListener("load", function(){
                        var e = document.body;
                        e.innerHTML = '';
                      });
                    }

      crawler = BrowserCrawler::Engine.new(max_pages: 1)
      crawler.js_before_run(javascript: javascript)
      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages[url][:extracted_links]

      expect(extracted_links).to eq([])
    end

    it 'overwrites before_crawling callback method and executes it' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}"

      crawler = BrowserCrawler::Engine.new(max_pages: 1)

      crawler.overwrite_callback(method: :before_crawling) do
        @report_store.record_page_visit(page:            "#{url}/before_crawling",
                                        extracted_links: ['link1'])
      end

      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages["#{url}/before_crawling"][:extracted_links]

      expect(extracted_links).to eq(['link1'])
    end


    it 'overwrites after_crawling callback method and executes it' do
      Capybara.server = :webrick
      Capybara::Server.new(app).boot
      url = "http://#{server.host}:#{server.port}"

      crawler = BrowserCrawler::Engine.new(max_pages: 1)

      crawler.overwrite_callback(method: :after_crawling) do
        @report_store.record_page_visit(page: "#{url}/after_crawling", extracted_links: ['link1'])
      end

      crawler.extract_links(url: url)

      extracted_links = crawler.report_store.pages["#{url}/after_crawling"][:extracted_links]

      expect(extracted_links).to eq(['link1'])
    end
  end
end
