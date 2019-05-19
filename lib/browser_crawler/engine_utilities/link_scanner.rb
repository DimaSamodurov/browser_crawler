module BrowserCrawler
  module EngineUtilities
    class LinkScanner

      attr_reader :link_inspector

      def initialize(link_inspector:)
        @link_inspector = link_inspector
      end

      def scan(page:)
        link_inspector.internal_url? ? get_page_links(page: page) : []
      end

      private

      def get_page_links(page:)
        remove_blank_links(page.all('a').map { |a| a['href'] })
      end

      def remove_blank_links(links)
        links.reject do |link|
          link.nil? || link.empty?
        end
      end
    end
  end
end
