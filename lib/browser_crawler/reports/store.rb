module BrowserCrawler
  module Reports
    # Value object that contains crawling results.
    # Example:
    # {
    #   pages: {
    #     '/':
    #       {
    #         screenshot: 'file1.png',
    #         error: nil,
    #         extracted_links: ['http://welcome[pdf]', 'http://support']
    #       },
    #     'welcome':
    #       {
    #         screenshot: 'file2.png',
    #         error: 'Invalid URI',
    #         extracted_links: nil
    #       }
    #   },
    #   metadata: {
    #     custom_attribute: 'Sample report title'
    #   },
    #   unrecognized_links: ['mailto://', 'javascript://'],
    #   started_at: 12345,
    #   finished_at: 123456
    # }

    # It involves methods which allow to save data to a store structure
    class Store
      attr_reader :pages, :metadata, :unrecognized_links
      attr_accessor :error

      def initialize(pages: {}, metadata: {}, started_at: nil, finished_at: nil)
        @pages = pages
        @metadata = metadata
        @started_at = started_at
        @finished_at = finished_at
        @unrecognized_links = []
      end

      def start(url:)
        @pages.clear
        @started_at = Time.now
        @metadata[:url] = url
      end

      def finish
        @finished_at = Time.now
      end

      def to_h
        {}.merge(pages: @pages)
          .merge(@metadata)
          .merge(
            unrecognized_links: @unrecognized_links,
            started_at: @started_at,
            finished_at: @finished_at
          )
      end

      def record_unrecognized_link(link)
        @unrecognized_links << link unless @unrecognized_links.include?(link)
      end

      def record_page_visit(page:,
                            extracted_links: nil,
                            screenshot_filename: nil,
                            error: nil,
                            links_found: 0,
                            external: false,
                            code: nil)
        @pages[page] = {
          screenshot:      screenshot_filename,
          error:           error,
          extracted_links: extracted_links,
          code:            code,
          links_found:     links_found,
          external:        external
        }
      end

      def visited_pages
        @pages.keys
      end
    end
  end
end
