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

  describe '#overwrite_callback' do
    it 'overwrites available callback method' do
      crawler = described_class.new
      crawler.overwrite_callback(method: :before_crawling) do
        report_store.record_page_visit(page: 'test')
      end

      expect(crawler.report_store.pages).to eq({})
      crawler.before_crawling

      expect(crawler.report_store.pages.keys).to eq(['test'])
    end

    it 'checks available callback methods' do
      exist_methods = BrowserCrawler::Engine::AVAILABLE_CALLBACK_METHODS
      expect(exist_methods).to eq(%i[before_crawling
                                     after_crawling
                                     before_scan_page])
    end

    it 'raises error when overwrote unavailable callback method' do
      crawler = described_class.new

      message = 'Overwrite unavailable callback method: before_xxx'

      expect do
        crawler.overwrite_callback(method: :before_xxx) do
          report_store.record_page_visit(page: 'test')
        end
      end.to raise_error(
        BrowserCrawler::Engine::UnavailableCallBackMethod, message
      )
    end
  end
end
