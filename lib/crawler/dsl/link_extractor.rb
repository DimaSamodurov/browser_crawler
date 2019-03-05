module Crawler
  module Dsl
    class LinkExtractor
      include DslOrganizer::ExportCommand[:extract_links_for]

      def call(url, path = false)
        crawler.extract_links(url: url, only_path: path)
        crawler.report_save
      end

      def crawler
        @crawler ||= Crawler::Engine.new(options)
      end

      private

      def options
        configuration = DslOrganizer::CommandContainer[:configuration]
        if configuration
          DslOrganizer::CommandContainer[:configuration].options
        else
          Configuration::DEFAULT_OPTIONS
        end
      end
    end
  end
end