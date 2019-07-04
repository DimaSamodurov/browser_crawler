require_relative '../url_tools'
require_relative 'link_inspector'
require_relative 'page_inspector'
require_relative '../hooks_operator'

module BrowserCrawler
  module EngineUtilities
    class CrawlManager
      include Capybara::DSL
      include HooksOperator

      attr_reader :target_url,
                  :unvisited_links_queue,
                  :report_store,
                  :host_name,
                  :deep_visit,
                  :max_pages,
                  :logger,
                  :page_inspector

      def initialize(report_store:,
                     max_pages: 0,
                     deep_visit: false,
                     logger: nil)
        @report_store     = report_store
        @max_pages        = max_pages
        @deep_visit       = deep_visit
        @logger           = logger || Logger.new(STDOUT)
      end

      def crawl(target_url:, capybara_session:, screenshot_operator: nil)
        @host_name             = UrlTools.uri!(url: target_url).host
        @unvisited_links_queue = [target_url]

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
        @page_inspector = PageInspector.new(
          link_inspector: link_inspector,
          capybara_session: capybara_session,
          report_store: report_store
        )

        logger.info("Visiting #{link_inspector.raw_link}")
        @page_inspector.visit_page

        @page_inspector.save_to_report(screenshot_operator: screenshot_operator)

        logger.info("#{@page_inspector.scan_result.size} links found on the page.")

        unvisited_links = get_unvisited_links

        logger.info("#{unvisited_links.size} will add to unvisited links queue.")

        return unless add_to_queue?(links: unvisited_links)

        unvisited_links_queue.push(*unvisited_links).uniq!

        logger.info("#{unvisited_links_queue.size} - current state the queue.")

      rescue StandardError => error
        error_link = "visiting link - #{link_inspector.raw_link};\n"
        error_message = "error message: #{error.message};\n"
        error_backtrace = "error backtrace: #{error.backtrace.join("\n")};\n"
        logger.info("Error: #{error_link} #{error_message} #{error_backtrace}")
      end

      def add_to_queue?(links:)
        links && !links.empty?
      end

      def internal_resource?(link_inspector)
        link_inspector.internal_url? || deep_visit
      end

      def page_unvisited?(link_inspector)
        !visited_pages.include?(link_inspector.full_url)
      end

      def limit_reached?
        return false if max_pages.zero?

        visited_pages.count >= max_pages
      end

      def visited_pages
        report_store.visited_pages
      end

      # returns array consists of unvisited_links
      # if some hooks is existed to execute hooks instead of base behavior
      def get_unvisited_links
        exchange_on_hooks(type: :unvisited_links) do
          @page_inspector.scan_result
        end
      end
    end
  end
end
