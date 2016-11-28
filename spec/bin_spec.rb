require 'spec_helper'
require 'rack'

describe 'command line `crawl URL`' do
  let(:server) do
    app = lambda { |env| [200, {}, ["Hi there!"]] }
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

describe 'command line `crawl -s`' do
  let(:server) do
    app = lambda { |env| [200, {}, ["Hi there!"]] }
    Capybara::Server.new(app).boot
  end

  let(:url) do
    "http://#{server.host}:#{server.port}/"
  end

  report_file = Crawler::Options.default_options[:output]

  context 'standalone, when URL is not specified' do
    it "creates an html index from screenshots found in the folder." do
      tmp_dir = File.expand_path('../tmp/screenshots', __dir__)
      `mkdir #{tmp_dir}`

      (1..3).each do |i|
        File.write(File.join(tmp_dir, "image#{i}.png"), "stub")
      end

      index_file = File.join(tmp_dir, 'index.html')

      `rm #{index_file}`
      expect(File.exists?(index_file)).to be_falsey

      `bin/crawl -s #{tmp_dir}`

      expect(File.exists?(index_file)).to be_truthy
    end
  end
end
