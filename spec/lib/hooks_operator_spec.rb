require 'spec_helper'

describe BrowserCrawler::HooksOperator do
  before :each do
    lambda do
      return nil unless Object.constants.include?(:ClassSubject)

      Object.send(:remove_const, :ClassSubject)
    end.call
  end

  describe '.with_hooks_for' do
    it 'executes hooks with type :all for a passed block' do
      ClassSubject = Class.new do
        include BrowserCrawler::HooksOperator

        def before(type: :all, &hook)
          BrowserCrawler::HooksContainer.instance.add_hook(method: :before,
                                                           type:   type,
                                                           hook:   hook)
        end

        def after(type: :all, &hook)
          BrowserCrawler::HooksContainer.instance.add_hook(method: :after,
                                                           type:   type,
                                                           hook:   hook)
        end
      end

      message = []

      subject = ClassSubject.new

      subject.before(type: :all) do
        message << 'before all'
      end

      subject.after(type: :all) do
        message << 'after all'
      end

      subject.after(type: :each) do
        message << 'after each'
      end

      subject.with_hooks_for(type: :all) do
        message << 'body'
      end

      expect(message).to eq(['before all', 'body', 'after all'])
    end

    it 'executes hooks with type :each for a passed block' do
      ClassSubject = Class.new do
        include BrowserCrawler::HooksOperator

        def before(type: :all, &hook)
          BrowserCrawler::HooksContainer.instance.add_hook(method: :before,
                                                           type:   type,
                                                           hook:   hook)
        end

        def after(type: :all, &hook)
          BrowserCrawler::HooksContainer.instance.add_hook(method: :after,
                                                           type:   type,
                                                           hook:   hook)
        end
      end

      message = []

      subject = ClassSubject.new

      subject.before(type: :each) do
        message << 'before each'
      end

      subject.after(type: :each) do
        message << 'after each'
      end

      subject.after(type: :all) do
        message << 'after all'
      end

      subject.with_hooks_for(type: :each) do
        message << 'body'
      end

      expect(message).to eq(['before each', 'body', 'after each'])
    end
  end

  describe '.exchange_on_hooks' do
    it 'executes hooks with type :scan_rules or :unvisited_links' do
      ClassSubject = Class.new do
        include BrowserCrawler::HooksOperator

        def unvisited_links(&hook)
          BrowserCrawler::HooksContainer.instance
            .add_hook(method: :run_only_one,
                      type:   :unvisited_links,
                      hook:   hook)
        end
      end

      links_array = [1, 2, 3, 4]

      subject = ClassSubject.new

      subject.unvisited_links do
        links_array.select! { |i| i.even? }
      end

      subject.exchange_on_hooks(type: :unvisited_links) do
        links_array.select! { |i| i.odd? }
      end

      expect(links_array).to eq([2, 4])
    end
  end
end
