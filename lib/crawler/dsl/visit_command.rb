require 'capybara'
require 'capybara-screenshot'

module Crawler
  module Dsl
    class VisitCommand
      include DslOrganizer::ExportCommand[:visit_to]
      include ::Capybara::DSL

      def call(target_url)
        uri = URI(target_url.to_s)
        Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        visit uri.path
      end
    end
  end
end