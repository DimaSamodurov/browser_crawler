require 'spec_helper'

describe BrowserCrawler::Reports::YamlReport do
  describe '#export' do
    it 'exports to yaml file' do
      scan_result = {
        pages: {
          '/': {
            extracted_links: [
              '/help'
            ]
          },
          '/home': {
            extracted_links: [
              '/search'
            ]
          }
        }, metadata: {}
      }

      store = BrowserCrawler::Reports::Store.new(scan_result)

      exporter = described_class.new(store: store)

      Dir.mktmpdir do |folder_path|
        exporter.export(save_folder_path: folder_path)

        yaml_result = YAML.load_file("#{folder_path}/crawler_report.yaml")

        expect(yaml_result).to eq(
          pages: {
            '/': {
              extracted_links: [
                '/help'
              ]
            },
            '/home': {
              extracted_links: [
                '/search'
              ]
            }
          },
          finished_at: nil,
          links_count: 2,
          started_at: nil,
          unrecognized_links: []
        )
      end
    end
  end
end
