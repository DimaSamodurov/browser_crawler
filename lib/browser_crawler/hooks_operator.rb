module BrowserCrawler
  module HooksOperator
    def with_hooks_for(type:)
      run_before_hooks(type: type)
      yield
      run_after_hooks(type: type)
    end

    private

    def run_before_hooks(type:)
      before_hook = BrowserCrawler::HooksContainer.instance
                                                  .hooks_container[:before][type]
      return unless before_hook

      run_hooks(before_hook)
    end

    def run_after_hooks(type:)
      after_hook = BrowserCrawler::HooksContainer.instance
                                                 .hooks_container[:after][type]
      return unless after_hook

      run_hooks(after_hook)
    end

    def run_hooks(hooks)
      hooks.each do |hook|
        instance_exec(&hook)
      end
    end
  end
end
