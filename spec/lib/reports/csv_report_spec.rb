require 'spec_helper'

describe BrowserCrawler::Reports::CsvReport do
  describe '#export' do
    it 'exports to csv file' do
      store = BrowserCrawler::Reports::Store.new(pages: {
                                                   '/': {
                                                     extracted_links: [
                                                       '/help',
                                                       '/search'
                                                     ]
                                                   },
                                                   '/home': {
                                                     extracted_links: [
                                                       '/',
                                                       '/login'
                                                     ]
                                                   },
                                                   '/fail': {
                                                     extracted_links: nil
                                                   }
                                                 }, metadata: {})

      exporter = described_class.new(store: store)

      Dir.mktmpdir do |folder_path|
        csv_result = []

        exporter.export(save_folder_path: folder_path)

        CSV.foreach("#{folder_path}/crawler_report.csv") do |row|
          csv_result << row
        end

        expect(csv_result).to eq([['pages', 'extracted links'],
                                  ['/', '/help'],
                                  ['/', '/search'],
                                  ['/home', '/'],
                                  ['/home', '/login']])
      end
    end
  end
end
