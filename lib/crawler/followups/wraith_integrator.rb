require 'yaml'
require 'active_support/core_ext/string'
module Crawler
  module Followups
    # Updates the :paths section of the Wraith's config file.
    class WraithIntegrator
      def initialize(report:)
        @report = if report.respond_to?(:pages)
                    report
                  else
                    YAML.load(report)
                  end

      end

      def update_config(wraith_config_file, path_suffix: nil)
        config = YAML.load(File.read(wraith_config_file))
        config['paths'] = paths(with_suffix: path_suffix)
        File.write(wraith_config_file, config.to_yaml)
      end

      # @return [Hash] sorted hash of page_name => path pair values appended with optional suffix.
      #     Page name equals to path which makes it easy to navigate the page from the Wraith gallery.
      def paths(with_suffix: nil)
        Hash[sorted_pages.map { |(k, v)| [k, "#{v}#{with_suffix}"] }]
      end

      def named_pages
        @report.pages.inject({}) do |h, (page_url, links)|
          page_path = URI(page_url.to_s).path
          page_name = page_path.parameterize
          h[page_name] = page_path
          h
        end
      end

      def sorted_pages
        Hash[named_pages.sort_by { |(k, v)| k }]
      end
    end
  end
end
