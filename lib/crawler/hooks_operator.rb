module Crawler
  module HooksOperator

      def with_hooks_for_each_page
        run_before_hooks(type: :each)
        yield
        run_after_hooks(type: :each)
      end

      def with_hooks_for_all_pages
        run_before_hooks(type: :all)
        yield
        run_after_hooks(type: :all)
      end

      private

      def run_before_hooks(type:)
        before_hook = DslOrganizer::CommandContainer[:before]
        return unless before_hook
        run_hooks(before_hook.hooks[type])
      end

      def run_after_hooks(type:)
        after_hook = DslOrganizer::CommandContainer[:after]
        return unless after_hook
        run_hooks(after_hook.hooks[type])
      end

      def run_hooks(hooks)
        hooks.each {|hook| instance_exec(&hook)}
      end
  end
end
