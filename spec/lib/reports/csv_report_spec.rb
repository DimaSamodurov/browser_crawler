require 'spec_helper'

describe BrowserCrawler::Reports::CsvReport do
  describe '#export' do
    it 'exports to csv file' do
      store = BrowserCrawler::Reports::Store.new(
        pages: {
          '/': {
            extracted_links: %w[http:/github.com/help http:/github.com/search javascript://:],
            external: false,
            code: 200
          },
          '/home': {
            extracted_links: %w[http:/github.com/ http:/github.com/login mailto:],
            external: false,
            code: 204
          },
          '/blank': {
            extracted_links: nil,
            code: 401
          },
          '/search': {
            extracted_links: nil,
            code: 301
          }
        }, metadata: {}
      )

      exporter = described_class.new(store: store)

      Dir.mktmpdir do |folder_path|
        csv_result = []

        exporter.export(save_folder_path: folder_path)

        CSV.foreach("#{folder_path}/crawler_report.csv") do |row|
          csv_result << row
        end

        expect(csv_result)
          .to eq([['pages',
                   'extracted links',
                   'external?',
                   'http status',
                   'http code'],
                  ['/', 'http:/github.com/help', 'false', 'active', '200'],
                  ['/', 'http:/github.com/search', 'false', 'active', '200'],
                  ['/home', 'http:/github.com/', 'false', 'active', '204'],
                  ['/home', 'http:/github.com/login', 'false', 'active', '204'],
                  ['/blank', nil, nil, 'unauthorized', '401'],
                  ['/search', nil, nil, 'redirect', '301']])
      end
    end
  end
end
