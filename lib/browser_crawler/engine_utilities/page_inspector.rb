require_relative '../url_tools'
require_relative 'link_scanner'

module BrowserCrawler
  module EngineUtilities
    class PageInspector
      include Capybara::DSL

      attr_reader :link_inspector,
                  :link_scanner,
                  :capybara_session,
                  :result,
                  :report_store

      def initialize(link_inspector:, capybara_session:, report_store:)
        @link_inspector = link_inspector
        @capybara_session = Capybara.current_session
        @report_store = report_store

        @link_scanner = LinkScanner.new(link_inspector: link_inspector)
      end

      def visit_page
        uri = link_inspector.uri
        Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"

        visit link_inspector.full_url

        before_page_scan

        @result = link_scanner.scan(page: capybara_session)
      end

      def save_to_report(screenshot_operator: nil)
        screenshot_path = save_screenshot(screenshot_operator)

        report_store.record_page_visit(
          page:                link_inspector.full_url,
          extracted_links:     result,
          screenshot_filename: screenshot_path,
          external:            link_inspector.external_url?,
          code:                capybara_session.status_code
        )
      end

      def before_page_scan; end

      def success?
        result && !result.empty?
      end

      private

      def save_screenshot(screenshot_operator)
        return unless screenshot_operator&.save_screenshots?

        capybara_session.save_screenshot(
          screenshot_operator.file_path(url: capybara_session.current_url)
        )
      end
    end
  end
end
