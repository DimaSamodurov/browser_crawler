require_relative '../url_tools'
require_relative 'link_inspector'
require_relative 'page_inspector'

module BrowserCrawler
  module EngineUtilities
    class CrawlManager

      attr_reader :target_url,
                  :unvisited_links_queue,
                  :report_store,
                  :host_name,
                  :deep_visit,
                  :max_pages,
                  :logger

      def initialize(report_store:,
                     max_pages:,
                     deep_visit:,
                     logger: nil)
        @report_store     = report_store
        @max_pages        = max_pages
        @deep_visit       = deep_visit
        @logger           = logger
      end

      def crawl(target_url:, capybara_session:, screenshot_operator: nil)
        configurate_links_queue(target_url: target_url)

        loop do
          break if unvisited_links_queue.empty? || limit_reached?

          unvisited_link = unvisited_links_queue.shift

          link_inspector = LinkInspector.new(raw_link: unvisited_link,
                                             host_name: host_name)

          unless link_valid?(link_inspector)
            @logger.info("Skipped visited #{unvisited_link}")
            report_store.record_unrecognized_link(unvisited_link)
            next
          end

          inspect_page(link_inspector: link_inspector,
                       capybara_session: capybara_session,
                       screenshot_operator: screenshot_operator)
        end
      end

      def link_valid?(link_inspector)
        link_inspector.link_valid? &&
          internal_resource?(link_inspector) &&
          page_unvisited?(link_inspector)
      end

      private

      def inspect_page(link_inspector:, capybara_session:, screenshot_operator:)
        page_inspector = PageInspector.new(
          link_inspector: link_inspector,
          capybara_session: capybara_session,
          report_store: report_store
        )

        logger.info("Visiting #{link_inspector.raw_link}")
        page_inspector.visit_page

        page_inspector.save_to_report(screenshot_operator: screenshot_operator)

        if page_inspector.success?
          logger.info("#{page_inspector.result.size} links found on the page.")
          unvisited_links_queue.push(*page_inspector.result)
        end
      end

      def configurate_links_queue(target_url:)
        @host_name             = UrlTools.uri!(url: target_url).host
        @unvisited_links_queue = [target_url]
      end

      def internal_resource?(link_inspector)
        link_inspector.internal_url? || deep_visit
      end

      def page_unvisited?(link_inspector)
        ! visited_pages.include?(link_inspector.full_url)
      end

      def limit_reached?
        return false if max_pages.zero?

        visited_pages.count >= max_pages
      end

      def visited_pages
        report_store.visited_pages
      end
    end
  end
end
