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
          csv << ['pages',
                  'extracted links',
                  'external?',
                  'http status',
                  'http code']

          @store.pages.each do |page, crawler_result|
            status = humanize_code(crawler_result[:code])
            if crawler_result[:extracted_links].nil?
              csv << [page,
                      nil,
                      crawler_result[:external],
                      status,
                      crawler_result[:code]]
              next
            end

            crawler_result[:extracted_links].each do |link|
              csv << [page,
                      link,
                      crawler_result[:external],
                      status,
                      crawler_result[:code]]
            end
          end
        end
      end

      private

      def humanize_code(code)
        case code.to_i
        when 200..225 then :active
        when 401 then :unauthorized
        when 301..308 then :redirect
        else
          :broken
        end
      end
    end
  end
end
