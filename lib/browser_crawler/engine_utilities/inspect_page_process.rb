require_relative '../hooks_operator'

module BrowserCrawler
  module EngineUtilities
    # Inspect a passed link and update the loop queue if it is necessary.
    class InspectPageProcess
      include Capybara::DSL
      include HooksOperator

      attr_reader :page_inspector,
                  :screenshot_operator,
                  :link_inspector,
                  :logger

      def initialize(link_inspector:,
                     capybara_session:,
                     report_store:,
                     screenshot_operator: nil,
                     logger:)
        @page_inspector = PageInspector.new(
          link_inspector: link_inspector,
          capybara_session: capybara_session,
          report_store: report_store
        )
        @link_inspector = link_inspector
        @screenshot_operator = screenshot_operator
        @logger = logger
      end

      def call(unvisited_links_queue:)
        visit_page
        update_queue(unvisited_links_queue: unvisited_links_queue)
      end

      private

      def add_to_queue?(links:)
        links && !links.empty?
      end

      # returns array consists of unvisited_links
      # if some hooks is existed to execute hooks instead of base behavior
      def find_unvisited_links
        exchange_on_hooks(type: :unvisited_links) do
          @page_inspector.scan_result
        end
      end

      def visit_page
        logger.info("Visiting #{link_inspector.raw_link}")

        @page_inspector.visit_page

        @page_inspector.save_to_report(screenshot_operator: screenshot_operator)

        logger
          .info("#{@page_inspector.scan_result.size} links found on the page.")
      end

      def update_queue(unvisited_links_queue:)
        unvisited_links = find_unvisited_links

        logger
          .info("#{unvisited_links.size} will add to unvisited links queue.")

        return unless add_to_queue?(links: unvisited_links)

        unvisited_links_queue.push(*unvisited_links).uniq!

        logger.info("#{unvisited_links_queue.size} - current state the queue.")
      end
    end
  end
end
