require 'spec_helper'
require 'rack'

describe BrowserCrawler::EngineUtilities::InspectPageProcess do
  describe '#call' do
    it 'visits page, updates report and adds new link to queue' do
      unvisited_links_queue = []

      allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
        .to(receive(:scan).and_return(%w[/welcome /help]))
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      report_store = BrowserCrawler::Reports::Store.new

      process = described_class.new(link_inspector: link_inspector,
                                    capybara_session: Capybara.current_session,
                                    report_store: report_store,
                                    logger: Logger.new(STDOUT))

      process.call(unvisited_links_queue: unvisited_links_queue)

      expect(unvisited_links_queue).to eq(['/welcome', '/help'])
    end

    it 'checks logger information' do
      logger = double('logger')
      unvisited_links_queue = []

      allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
        .to(receive(:scan).and_return(%w[/welcome /help]))
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      report_store = BrowserCrawler::Reports::Store.new

      process = described_class.new(link_inspector: link_inspector,
                                    capybara_session: Capybara.current_session,
                                    report_store: report_store,
                                    logger: logger)

      expect(logger).to receive(:info).exactly(4).times

      process.call(unvisited_links_queue: unvisited_links_queue)
    end

    it 'does not add empty links array' do
      logger = double('logger')
      unvisited_links_queue = []

      allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
        .to(receive(:scan).and_return([]))
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      report_store = BrowserCrawler::Reports::Store.new

      process = described_class.new(link_inspector: link_inspector,
                                    capybara_session: Capybara.current_session,
                                    report_store: report_store,
                                    logger: logger)

      expect(logger).to receive(:info).exactly(3).times

      process.call(unvisited_links_queue: unvisited_links_queue)

      expect(unvisited_links_queue).to eq([])
    end

    it 'only adds uniq links' do
      unvisited_links_queue = ['/welcome']

      allow_any_instance_of(BrowserCrawler::EngineUtilities::LinkScanner)
        .to(receive(:scan).and_return(['/welcome', '/login']))
      allow_any_instance_of(Capybara::Session)
        .to receive(:status_code).and_return(200)
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      report_store = BrowserCrawler::Reports::Store.new

      process = described_class.new(link_inspector: link_inspector,
                                    capybara_session: Capybara.current_session,
                                    report_store: report_store,
                                    logger: Logger.new(STDOUT))

      process.call(unvisited_links_queue: unvisited_links_queue)

      expect(unvisited_links_queue).to eq(['/welcome', '/login'])
    end
  end
end
