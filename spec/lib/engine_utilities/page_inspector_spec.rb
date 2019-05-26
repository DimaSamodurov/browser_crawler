require 'spec_helper'

describe BrowserCrawler::EngineUtilities::PageInspector do
  describe '#visit_page' do
    it 'scans a page and sets up got value to links variable' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{ 'href' => '/home' },
                                                { 'href' => '/login' },
                                                { 'href' => '/success' }])
      allow(Capybara.current_session).to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class
                       .new(link_inspector: link_inspector,
                            capybara_session: Capybara.current_session,
                            report_store: report_store)

      page_inspector.visit_page

      expect(page_inspector.scan_result).to eq(%w[/home /login /success])
    end
  end

  describe '#success?' do
    it 'returns true if links were found on a page' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{ 'href' => '/home' },
                                                { 'href' => '/login' },
                                                { 'href' => '/success' }])
      allow(Capybara.current_session).to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(
        link_inspector: link_inspector,
        capybara_session: Capybara.current_session,
        report_store: report_store
      )

      page_inspector.visit_page

      expect(page_inspector.success?).to eq(true)
    end
  end

  describe '#save_to_report' do
    it 'saves scan_result to report without screenshot' do
      allow_any_instance_of(Capybara::Session)
        .to receive(:all).with('a').and_return([{ 'href' => '/home' },
                                                { 'href' => '/login' },
                                                { 'href' => '/success' }])
      allow_any_instance_of(Capybara::Session).to receive(:visit)
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(
        link_inspector: link_inspector,
        capybara_session: Capybara.current_session,
        report_store: report_store
      )

      page_inspector.visit_page
      page_inspector.save_to_report

      report_scan_result = { 'https://127.0.0.1/home' => {
        code: 200,
        error: nil,
        external: false,
        extracted_links: %w[/home /login /success],
        screenshot: nil
      } }

      expect(page_inspector.report_store.pages).to eq(report_scan_result)
    end

    it 'saves scan_result to report with screenshot' do
      screenshot_operator = BrowserCrawler::ScreenshotOperator
                            .new(save_screenshots: true)
      allow_any_instance_of(Capybara::Session)
        .to receive(:all).with('a').and_return([{ 'href' => '/home' },
                                                { 'href' => '/login' },
                                                { 'href' => '/success' }])
      allow_any_instance_of(Capybara::Session).to receive(:visit)
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)
      allow_any_instance_of(Capybara::Session)
        .to receive(:current_url).and_return('http://example.com/hello')
      allow_any_instance_of(Capybara::Session)
        .to receive(:save_screenshot).and_return('screenshot/path')

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(
        link_inspector: link_inspector,
        capybara_session: Capybara.current_session,
        report_store: report_store
      )

      page_inspector.visit_page
      page_inspector.save_to_report(screenshot_operator: screenshot_operator)

      report_scan_result = { 'https://127.0.0.1/home' => {
        code: 200,
        error: nil,
        external: false,
        extracted_links: %w[/home /login /success],
        screenshot: 'screenshot/path'
      } }

      expect(page_inspector.report_store.pages).to eq(report_scan_result)
    end
  end
end
