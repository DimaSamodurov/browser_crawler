require 'erb'
module BrowserCrawler
  module Followups
    # Indexes screenshots captured by the crawler, creates index.html from the captured screenshots.
    # ERB Template can be provided that will receive the list of files.
    class ScreenshotsIndexer
      def initialize(template:)
        @template = template || File.read(default_template_file)
      end

      # Produce index.html with links to screenshots found in the `path` specified.
      # Optionally file_mask can be provided to filter out files to be indexed.
      def index_directory(path, file_mask: '*.png')
        files = Dir[File.join(path, file_mask)].map{|file| File.basename(file) }
        html = render_index(files: files)
        index_path = File.join(path, 'index.html')
        File.write(index_path, html)
        index_path
      end

      def index_report(report)
        sorted_pages = Hash[report.pages.sort_by{|(k,v)| k}]
        files = Hash[sorted_pages.map do |(k,v)|
          k
        end]
      end

      private

      def default_template_file
        File.join(__dir__, 'templates/index.html.erb')
      end

      def render_index(files:)
        renderer = ERB.new(@template)
        renderer.result(binding)
      end
    end
  end
end
