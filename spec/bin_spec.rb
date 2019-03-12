require 'spec_helper'
require 'rack'

describe 'command line `crawl URL`' do
  let(:server) do
    app = lambda { |env| [200, {}, ["Hi there!"]] }
    Capybara.server = :webrick
    Capybara::Server.new(app).boot
  end

  let(:url) do
    "http://#{server.host}:#{server.port}/"
  end

  report_file = BrowserCrawler::Options.default_options[:report]

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

  report_file = BrowserCrawler::Options.default_options[:report]

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

    context 'with --wraith-config option' do
      let(:tmp_dir) { File.expand_path('../tmp', __dir__) }
      let(:report_file) { File.join(tmp_dir, 'wraith_config.yml') }
      let(:report) do
        <<-YAML
---
pages:
  "/":
    :status_code: 200
    :extracted_links:
    :screenshot: "tmp/stg/capybara-201611281738516158896902.png"
  "/welcome/computers":
    :status_code: 200
    :extracted_links:
    :screenshot: "tmp/stg/capybara-201611281738581708361847.png"
  "/mydevices/mobile":
    :status_code: 200
    :extracted_links:
        YAML
      end
      let(:wraith_config_file) { File.join(tmp_dir, 'wraith_config.yml') }
      let(:wraith_config) do
        <<-YAML
browser: phantomjs
domains:
  uat: https://localhost:3001/
  stg: https://localhost:3000/
screen_widths:
- 320
- 768
- 1024
- 1280
directory: shots
fuzz: 20%
threshold: 5
gallery:
  template: slideshow_template
  thumb_width: 200
  thumb_height: 200
mode: alphanumeric
paths:
  '': ''
        YAML
      end
      before do
        File.write(wraith_config_file, wraith_config)
      end

      xit 'update path: section of the wraith config file' do
        system("bin/crawl -c #{wraith_config_file}")
      end
    end
  end
end
