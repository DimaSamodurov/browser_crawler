require_relative '../url_tools'

module BrowserCrawler
  module EngineUtilities
    class LinkInspector
      attr_reader :raw_link, :host_name, :uri

      def initialize(raw_link:, host_name:)
        @raw_link = raw_link
        @host_name = host_name
        @uri = UrlTools.uri(url: raw_link)
      end

      def external_url?
        !internal_url?
      end

      def link_valid?
        @link_valid ||= !uri.nil? && uri.host && uri.scheme
      end

      def internal_url?
        @internal_url ||= !uri.nil? && uri.host == host_name
      end

      def full_url
        @full_url ||= UrlTools.full_url(uri: uri)
      end
    end
  end
end
