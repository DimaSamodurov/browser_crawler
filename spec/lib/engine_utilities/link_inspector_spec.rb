require 'spec_helper'

describe BrowserCrawler::EngineUtilities::LinkInspector do
  describe '#initialize' do
    it 'sets valid uri' do
      link_inspector = described_class.new(raw_link: 'https://127.0.0.1/home',
                                           host_name: '127.0.0.1')

      expect(link_inspector.uri).to eq(URI('https://127.0.0.1/home'))
    end

    it 'sets nil if links is not valid' do
      link_inspector = described_class.new(raw_link: 'https://127.0.0.1/home',
                                           host_name: '127.0.0.1')

      expect(link_inspector.uri).to eq(URI('https://127.0.0.1/home'))
    end
  end

  describe '#external_url?' do
    it 'returns true if url external' do
      link_inspector = described_class.new(raw_link: 'https://127.0.0.1/home',
                                           host_name: '127.1.1.1')

      expect(link_inspector.external_url?).to eq(true)
    end
  end

  describe '#internal_url?' do
    it 'returns true if url internal' do
      link_inspector = described_class.new(raw_link: 'https://127.0.0.1/home',
                                           host_name: '127.0.0.1')

      expect(link_inspector.internal_url?).to eq(true)
    end
  end

  describe '#full_url' do
    it 'returns full url (without slash end the end)' do
      link_inspector = described_class.new(raw_link: 'https://127.0.0.1/home/',
                                           host_name: '127.0.0.1')

      expect(link_inspector.full_url).to eq('https://127.0.0.1/home')
    end
  end
end
