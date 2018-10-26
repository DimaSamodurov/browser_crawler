module Crawler
  module DSL
    module JsHelpers
      def wait_for_page_to_load
        10.times do
          return if page.evaluate_script('document.readyState') == 'complete'
          sleep(0.5)
        end
      end
    end
  end
end
