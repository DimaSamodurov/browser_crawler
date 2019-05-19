require 'spec_helper'

describe BrowserCrawler::ScreenshotOperator do
  describe '.new' do
    it 'returns object with default options' do
      operator = described_class.new

      expect(operator.save_screenshots).to eq(false)
      expect(operator.screenshots_folder).to eq(nil)
      expect(operator.format).to eq('png')
      expect(operator.filename_base).to eq('screenshot')
    end
  end

  describe '#save_screenshots?' do
    it 'returns true when screenshots are had to save' do
      operator = described_class.new(save_screenshots: true)

      expect(operator.save_screenshots?).to eq(true)
    end

    it 'returns true when screenshots folder was set' do
      operator = described_class.new(save_screenshots_to: 'tmp')

      expect(operator.save_screenshots?).to eq(true)
    end

    it 'returns false when options have default values' do
      operator = described_class.new

      expect(operator.save_screenshots?).to eq(false)
    end
  end

  describe '#file_path' do
    it 'returns actual file path for default options' do
      operator = described_class.new

      expect(operator.file_path).to match(%r{tmp/screenshots})
    end

    it 'returns file path based on the url option' do
      operator = described_class.new

      expect(operator.file_path(url: 'http://127.0.0.1/home')).to match(/home/)
    end

    it 'returns file path based on screenshot folder' do
      operator = described_class.new(save_screenshots_to: 'random')

      expect(operator.file_path).to match(%r{random})
    end
  end

  describe '#filename' do
    it 'returns actual filename for default options' do
      operator = described_class.new

      expect(operator.filename).to match(/UTC_screenshot\.png/)
    end

    it 'returns filename based on the passed option' do
      operator = described_class.new(filename: 'example')

      expect(operator.filename).to match(/UTC_example\.png/)
    end
  end
end
