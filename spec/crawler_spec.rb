require 'spec_helper'
require 'rack'

describe Crawler do
  it 'has a version number' do
    expect(Crawler::VERSION).not_to be nil
  end

  let(:server) do
    fixture_path = File.expand_path('fixtures/static_site', __dir__)
    app = Rack::Builder.app do
      use Rack::Static, urls: {'/' => 'index.html'}, root: fixture_path
      run Rack::File.new(fixture_path)
    end
    Capybara::Server.new(app).boot
  end

  let(:url) do
    "http://#{server.host}:#{server.port}/"
  end

  it 'starts crawling with the path provided in the url' do
    crawler = Crawler::Engine.new
    crawler.extract_links(url: "#{url}page2.html")
    expect(crawler.visited_pages.first).to eql '/page2.html'
  end

  it 'extracts links from the page' do
    crawler = Crawler::Engine.new
    crawler.extract_links(url: url)

    extracted_links = crawler.report.pages['/'][:extracted_links]

    expect(extracted_links[0]).to match /page1.html/
    expect(extracted_links[1]).to match /page2.html/
    expect(extracted_links[2]).to match /page3.html/
  end

  it 'visits internal pages' do
    crawler = Crawler::Engine.new
    crawler.extract_links(url: url)
    internal_pages = %w[/ /page1.html /page11.html /page12.html /page2.html /page21.html]
    expect(internal_pages - crawler.report.visited_pages).to be_empty
  end

  describe 'with max_pages option specified' do
    it 'extracts visits not more than specified number of pages' do
      crawler = Crawler::Engine.new(max_pages: 2)
      crawler.extract_links(url: url)
      expect(crawler.report.visited_pages.count).to eql 2
    end
  end
end
