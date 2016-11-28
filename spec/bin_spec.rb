require 'spec_helper'
require 'rack'

describe 'command line `crawl URL`' do
  let(:server) do
    app = lambda { |env| [200, {}, ["Hi there!"]]}
    Capybara::Server.new(app).boot
  end

  let(:url) do
    "http://#{server.host}:#{server.port}/"
  end

  report_file = Crawler::Options.default_options[:output]

  it "outputs report to '#{report_file}' by default" do
    `rm #{report_file}`
    expect(File.exists?(report_file)).to be_falsey

    `bin/crawl #{url}`

    expect(File.exists?(report_file)).to be_truthy
  end
end

