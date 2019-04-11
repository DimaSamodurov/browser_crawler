require 'csv'
require 'pry'
module BrowserCrawler
  module Reports
    # It involves methods which allow to save a store to a csv file
    class CsvReport
      def initialize(store:)
        @store = store
      end

      def export(save_folder_path:)
        CSV.open("#{save_folder_path}/crawler_report.csv", 'wb') do |csv|
          csv << csv_header

          @store.pages.each do |page, crawler_result|
            save_to_csv(csv, page, crawler_result)
          end
        end
      end

      private

      def filter_links(links)
        return nil if links.nil?

        links.select do |link|
          begin
            uri = URI(link)
          rescue URI::InvalidURIError, URI::InvalidComponentError
            next
          end

          if uri.scheme
            link =~ /\A#{URI.regexp(%w[http https])}\z/
          else
            true
          end
        end
      end

      def save_to_row(page, crawler_result, link = nil)
        [page,
         link,
         crawler_result[:external],
         humanize_code(crawler_result[:code]),
         crawler_result[:code]]
      end

      def save_to_csv(csv, page, crawler_result)
        extracted_links = filter_links(crawler_result[:extracted_links])

        if extracted_links.nil?
          csv << save_to_row(page, crawler_result)
          return
        end

        extracted_links.each do |link|
          csv << save_to_row(page, crawler_result, link)
        end
      end

      def csv_header
        ['pages',
         'extracted links',
         'external?',
         'http status',
         'http code']
      end

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
