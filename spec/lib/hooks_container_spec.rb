require 'spec_helper'

describe BrowserCrawler::HooksContainer do
  describe '.hooks_container' do
    it 'returns empty hash' do
      expect(described_class.instance.hooks_container).to eq({})
    end
  end

  describe '.add_hook' do
    it 'adds a hook to hooks_container' do
      described_class.instance.add_hook(method: :before,
                                        type: :each)

      expect(described_class.instance.hooks_container)
        .to eq(before: { all: [], each: [nil] })
    end

    it 'raises error when type is invalid' do
      error_message = 'Passed hooks type `irregular` is invalid.' \
                      ' A type has to apply one of the follow values: each, all'

      expect do
        described_class
          .instance
          .add_hook(method: :before, type: :irregular)
      end.to raise_error(BrowserCrawler::Errors::InvalidHooksType,
                         error_message)
    end
  end
end
