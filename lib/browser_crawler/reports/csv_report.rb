require 'csv'

module BrowserCrawler
  module Reports
    # It involves methods which allow to save a store to a csv file
    class CsvReport
      def initialize(store:)
        @store = store
      end

      def export(save_folder_path:)
        CSV.open("#{save_folder_path}/crawler_report.csv", 'wb') do |csv|
          csv << ['pages', 'extracted links']

          @store.pages.each do |page, crawler_result|
            next if crawler_result[:extracted_links].nil?

            crawler_result[:extracted_links].each do |link|
              csv << [page, link]
            end
          end
        end
      end
    end
  end
end
