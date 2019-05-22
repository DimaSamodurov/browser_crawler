require 'spec_helper'

describe BrowserCrawler::EngineUtilities::PageInspector do
  describe '#visit_page' do
    it 'scans a page and sets up got value to links variable' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{'href' => '/home'},
                                                {'href' => '/login'},
                                                { 'href' => '/success'}])
      allow(Capybara.current_session).to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(link_inspector: link_inspector,
                                           capybara_session: Capybara.current_session,
                                           report_store: report_store)

      page_inspector.visit_page

      expect(page_inspector.result).to eq(['/home', '/login', '/success'])
    end
  end

  describe '#success?' do
    it 'returns true if links were found on a page' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{'href' => '/home'},
                                                {'href' => '/login'},
                                                { 'href' => '/success'}])
      allow(Capybara.current_session).to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(link_inspector: link_inspector,
                                           capybara_session: Capybara.current_session,
                                           report_store: report_store)

      page_inspector.visit_page

      expect(page_inspector.success?).to eq(true)
    end
  end

  describe '#save_to_report' do
    it 'saves result to report without screenshot' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{'href' => '/home'},
                                                {'href' => '/login'},
                                                { 'href' => '/success'}])
      allow(Capybara.current_session).to receive(:visit)
      allow(Capybara.current_session).to receive(:status_code).and_return(200)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )
      report_store = BrowserCrawler::Reports::Store.new

      page_inspector = described_class.new(link_inspector: link_inspector,
                                           capybara_session: Capybara.current_session,
                                           report_store: report_store)

      page_inspector.visit_page
      page_inspector.save_to_report

      report_result = { "https://127.0.0.1/home" => {
        :code=>200,
        :error=>nil,
        :external=>false,
        :extracted_links => ["/home", "/login", "/success"],
        :screenshot=>nil }
      }

      expect(page_inspector.report_store.pages).to eq(report_result)
    end

    it 'saves result to report with screenshot' do

    end
  end
end