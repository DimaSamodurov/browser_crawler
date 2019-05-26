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

  describe '#before' do
    describe ':each' do
      it 'executes hook before each page scan' do
        allow_any_instance_of(Capybara::Session).to receive(:visit)
        allow_any_instance_of(Capybara::Session).to receive(:status_code)
        allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
          .to receive(:scan)

        crawler = described_class.new(browser_options: {},
                                      screenshots_options: {})

        crawler.before(type: :each) do
          visit 'http://test.ru'
          report_store.record_page_visit(page: 'http://test.ru')
        end

        crawler.extract_links(url: 'http://example.com')

        expect(crawler.report_store.pages.keys)
          .to eq(%w[http://test.ru http://example.com])
      end
    end

    describe ':all' do
      it 'executes hook before all page scan' do
        allow_any_instance_of(Capybara::Session).to receive(:visit)

        crawler = described_class.new(browser_options: {},
                                      screenshots_options: {})

        allow_any_instance_of(BrowserCrawler::EngineUtilities::CrawlManager)
          .to receive(:crawl) do
          crawler.report_store.record_page_visit(page: 'https://success.com')
        end

        crawler.before(type: :all) do
          visit 'http://test.ru'
          report_store.record_page_visit(page: 'http://test.ru')
        end

        crawler.extract_links(url: 'http://example.com')

        expect(crawler.report_store.pages.keys)
          .to eq(%w[http://test.ru https://success.com])
      end
    end
  end

  describe '#after' do
    describe ':each' do
      it 'executes hook after each page scan' do
        allow_any_instance_of(Capybara::Session).to receive(:visit)
        allow_any_instance_of(Capybara::Session).to receive(:status_code)
        allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
          .to receive(:scan).and_return('https://success.com')

        crawler = described_class.new(browser_options: {},
                                      screenshots_options: {})

        crawler.after(type: :each) do
          visit 'http://test.ru'
          report_store
            .record_page_visit(page: instance_variable_get(:@scan_result))
        end

        crawler.extract_links(url: 'http://example.com')

        expect(crawler.report_store.pages.keys)
          .to eq(%w[https://success.com http://example.com])
      end
    end

    describe ':all' do
      it 'executes hook after all page scan' do
        allow_any_instance_of(Capybara::Session).to receive(:visit)

        crawler = described_class.new(browser_options: {},
                                      screenshots_options: {})

        allow_any_instance_of(BrowserCrawler::EngineUtilities::CrawlManager)
          .to receive(:crawl) do
          crawler.report_store.record_page_visit(page: 'https://success.com')
        end

        crawler.after(type: :all) do
          visit 'http://test.ru'
          report_store.record_page_visit(page: 'http://test.ru')
        end

        crawler.extract_links(url: 'http://example.com')

        expect(crawler.report_store.pages.keys)
          .to eq(%w[https://success.com http://test.ru])
      end
    end
  end
end
