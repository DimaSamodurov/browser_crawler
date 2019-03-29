require 'spec_helper'

describe BrowserCrawler::Reports::Store do
  describe '#to_h' do
    it 'returns report as hash' do
      report = described_class.new(pages: {
                                     '/': nil,
                                     '/home': nil
                                   }, metadata: {})

      expect(report.to_h).to eq(finished_at: nil,
                                pages: { '/': nil, '/home': nil },
                                started_at: nil)
    end
  end
end
