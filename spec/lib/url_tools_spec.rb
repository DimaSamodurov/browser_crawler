require 'spec_helper'

describe BrowserCrawler::UrlTools do
  describe '.uri' do
    it 'returns URI instance' do
      url = 'https://example.com'
      expect(described_class.uri(url: url)).to eq(URI(url))
    end

    it 'returns nil if url is invalid' do
      expect(described_class.uri(url: 'example.com')).to eq(nil)
    end
  end

  describe '.uri!' do
    it 'returns URI instance' do
      url = 'https://example.com'
      expect(described_class.uri(url: url)).to eq(URI(url))
    end

    it 'raises error if url invalid' do
      expect { described_class.uri!(url: 'example.com') }
        .to raise_error(URI::InvalidURIError)
    end
  end

  describe '.full_url' do
    it 'returns url as string from URI instance' do
      url = 'https://example.com'
      expect(described_class.full_url(uri: URI(url))).to eq(url)
    end

    it 'returns url as string with specific port from URI instance' do
      url = 'http://example.com:1234'
      expect(described_class.full_url(uri: URI(url))).to eq(url)
    end
  end
end
