require 'spec_helper'

describe BrowserCrawler::Reports::CsvReport do
  describe '#export' do
    it 'exports to csv file' do
      store = BrowserCrawler::Reports::Store.new(
        pages: {
          '/': {
            extracted_links: %w[/help /search],
            external: false,
            code: 200
          },
          '/home': {
            extracted_links: %w[/ /login],
            external: false,
            code: 200
          },
          '/blank': {
            extracted_links: nil
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
          .to eq([['pages', 'extracted links', 'http code', 'external?'],
                  ['/', '/help', '200', 'false'],
                  ['/', '/search', '200', 'false'],
                  ['/home', '/', '200', 'false'],
                  ['/home', '/login', '200', 'false'],
                  ['/blank', nil, nil, nil]])
      end
    end
  end
end
