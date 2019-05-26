module BrowserCrawler
  module Errors
    class InvalidHooksType < StandardError
      def initialize(invalid_type:)
        message = "Passed hooks type `#{invalid_type}` is invalid." \
                  ' A type has to apply one of the follow values:' \
                  " #{HooksContainer::VALID_TYPES.join(', ')}"
        super(message)
      end
    end
  end
end
