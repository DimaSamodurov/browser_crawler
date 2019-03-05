require 'spec_helper'
require 'rack'

describe Crawler::Dsl do
  it 'starts crawling with the path provided in the url' do
    fixture_path = File.expand_path('fixtures/static_site', __dir__)
    app = Rack::Builder.app do
      use Rack::Static, urls: {'/' => 'index.html'}, root: fixture_path
      run Rack::File.new(fixture_path)
    end
    Capybara.server = :webrick
    server = Capybara::Server.new(app).boot

    expect_any_instance_of(Crawler::Dsl::LinkExtractor).to receive(:call)

    Crawler.run do
      extract_links_for(url: "http://#{server.host}:#{server.port}/")
    end
  end
end