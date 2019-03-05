module Crawler
  module Dsl
    class Configuration
      include DslOrganizer::ExportCommand[:configuration]

      OPTIONS = [:screenshots_path, :max_pages, :window_width, :window_height]

      DEFAULT_OPTIONS = {
          window_width: 1280,
          window_height: 1600
      }

      def call
        yield(self)
      end

      def options
        @options ||= DEFAULT_OPTIONS
      end

      OPTIONS.each do |option|
        define_method option do |value|
          options[option] = value
        end
      end
    end
  end
end