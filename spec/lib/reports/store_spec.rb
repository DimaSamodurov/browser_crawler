require 'spec_helper'

describe BrowserCrawler::Reports::Store do
  describe '#to_h' do
    it 'returns store as hash' do
      store = described_class.new(pages: {
                                    '/': nil,
                                    '/home': nil
                                  }, metadata: {})

      expect(store.to_h).to eq(finished_at: nil,
                               pages: { '/': nil, '/home': nil },
                               links_count: nil,
                               started_at: nil,
                               unrecognized_links: [])
    end
  end

  describe '#record_unrecognized_link' do
    it 'adds to array only unique links' do
      store = described_class.new
      store.record_unrecognized_link('mailto://')

      expect(store.unrecognized_links).to eq(['mailto://'])

      store.record_unrecognized_link('mailto://')

      expect(store.unrecognized_links).to eq(['mailto://'])
    end
  end

  describe '#record_page_visit' do
    it 'records data related the visited page' do
      store = described_class.new
      store.record_page_visit(
        page: '/home',
        screenshot_filename: 'tmp',
        error: 'some error',
        extracted_links: ['/page1.html'],
        code: 200,
        external: false
      )
      expect(store.pages).to eq(
        '/home' => {
          screenshot: 'tmp',
          error: 'some error',
          extracted_links: ['/page1.html'],
          code: 200,
          external: false
        }
      )
    end
  end
end
