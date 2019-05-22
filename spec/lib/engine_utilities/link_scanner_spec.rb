require 'spec_helper'

describe BrowserCrawler::EngineUtilities::LinkScanner do
  describe '#scan' do
    it 'returns links from the page' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{'href' => '/home'},
                                                 {'href' => '/login'},
                                                 { 'href' => '/success'}])
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      link_scanner = described_class.new(link_inspector: link_inspector)

      expect(link_scanner.scan(page: Capybara.current_session))
        .to eq(['/home', '/login', '/success'])
    end

    it 'returns only filled links' do
      allow(Capybara.current_session)
        .to receive(:all).with('a').and_return([{'href' => '/home'},
                                                {'href' => nil },
                                                { 'href' => ''}])

      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.0.0.1'
      )

      link_scanner = described_class.new(link_inspector: link_inspector)

      expect(link_scanner.scan(page: Capybara.current_session))
        .to eq(['/home'])
    end

    it 'returns an empty array for an external link' do
      link_inspector = BrowserCrawler::EngineUtilities::LinkInspector.new(
        raw_link: 'https://127.0.0.1/home',
        host_name: '127.9.9.9'
      )

      link_scanner = described_class.new(link_inspector: link_inspector)

      expect(link_scanner.scan(page: Capybara.current_session)).to eq([])
    end
  end
end