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
          csv << ['pages', 'extracted links', 'http code', 'external?']

          @store.pages.each do |page, crawler_result|
            if crawler_result[:extracted_links].nil?
              csv << [page,
                      nil,
                      crawler_result[:code],
                      crawler_result[:external]]
              next
            end

            crawler_result[:extracted_links].each do |link|
              csv << [page,
                      link,
                      crawler_result[:code],
                      crawler_result[:external]]
            end
          end
        end
      end
    end
  end
end
