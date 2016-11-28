module Crawler
  module Reports
    class Simple
      attr_reader :pages, :metadata, :error

      def initialize
        @pages = {}
        @metadata = {}
      end

      def start(url:)
        @pages.clear
        @started_at = Time.now
        @metadata[:url] = url
      end

      def finish
        @finished_at = Time.now
      end

      def record_page_visit(page:, extracted_links: nil, screenshot_filename: nil, error: nil)
        @pages[page] = {
          extracted_links: extracted_links,
          screenshot: screenshot_filename,
          error: error
        }
      end

      def visited_pages
        @pages.keys
      end
    end
  end
end
