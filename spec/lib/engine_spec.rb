require 'spec_helper'

describe BrowserCrawler::Engine do
  describe '#report_save' do
    it 'saves default report to default folder' do
      `rm -rf tmp`
      crawler = described_class.new

      crawler.report_save

      expect(File.directory?('tmp')).to be true

      `rm -rf tmp`
    end
  end
end
