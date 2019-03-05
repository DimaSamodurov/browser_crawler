require 'dsl_organizer/export_command'

module Crawler
  module Dsl
    module Hooks
      class AfterHook
        include DslOrganizer::ExportCommand[:after]

        def call(type, &block)
          hook_type = type.nil? ? :all : type.to_sym
          hooks[hook_type].unshift(block)
        end

        def hooks
          @hooks ||= {
              all: [],
              each: []
          }
        end
      end
    end
  end
end