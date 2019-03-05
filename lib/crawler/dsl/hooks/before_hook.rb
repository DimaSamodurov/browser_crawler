module Crawler
  module Dsl
    module Hooks
      class BeforeHook
        include DslOrganizer::ExportCommand[:before]

        def call(type, &block)
          hook_type = type.nil? ? :all : type.to_sym
          hooks[hook_type].push(block)
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