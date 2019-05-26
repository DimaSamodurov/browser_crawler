require 'singleton'
require_relative 'errors/invalid_hooks_type'

module BrowserCrawler
  class HooksContainer
    include Singleton

    VALID_TYPES = %i[each all].freeze

    def initialize
      reset
    end

    def reset
      @hooks_container = Hash.new { |h, k| h[k] = { each: [], all: [] } }
    end

    attr_reader :hooks_container

    def add_hook(method:, type:, hook: nil)
      unless VALID_TYPES.include?(type)
        raise Errors::InvalidHooksType.new(invalid_type: type)
      end

      @hooks_container[method][type.to_sym] << hook
    end
  end
end
