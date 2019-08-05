module BrowserCrawler
  module EngineUtilities
    class LinkScanner
      include Capybara::DSL
      include HooksOperator

      attr_reader :link_inspector

      def initialize(link_inspector:)
        @link_inspector = link_inspector
      end

      def scan(page:)
        link_inspector.internal_url? ? get_page_links(page: page) : []
      end

      private

      def get_page_links(page:)
        remove_blank_links(link_matcher(page: page))
      end

      def remove_blank_links(links)
        links.reject do |link|
          link.nil? || link.empty?
        end
      end

      # return Array consists of links from page
      # if hooks exists when execute them instead of basic behavior
      def link_matcher(page:)
        exchange_on_hooks(type: :scan_rules) do
          page.all('a').map { |a| a['href'] }
        end
      end
    end
  end
end
