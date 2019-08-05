module BrowserCrawler
  module HooksOperator
    def with_hooks_for(type:)
      run_before_hooks(type: type)
      yield
      run_after_hooks(type: type)
    end

    def exchange_on_hooks(type:, &default_block)
      hooks_array = BrowserCrawler::HooksContainer
              .instance.hooks_container[:run_only_one][type]

      if hooks_array && !hooks_array.empty?
        instance_exec(&hooks_array[0])
      elsif block_given?
        instance_exec(&default_block)
      end
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
