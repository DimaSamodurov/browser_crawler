module Crawler
  module DSL
    module JsHelpers
      def wait_for_page_to_load
        loop until page.evaluate_script('jQuery.active').zero?
      end
    end
  end
end
