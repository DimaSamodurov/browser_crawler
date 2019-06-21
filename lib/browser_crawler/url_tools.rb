module BrowserCrawler
  module UrlTools
    def uri(url:)
      uri!(url: url)
    rescue URI::InvalidURIError
      nil
    end

    def uri!(url:)
      string_url = url.to_s
      raise URI::InvalidURIError unless string_url =~ /\A#{URI.regexp(%w[http https])}\z/

      URI(string_url)
    end

    def full_url(uri:)
      path_query = get_path_query(uri: uri)
      if uri.port == 80 || uri.port == 443
        "#{uri.scheme}://#{uri.host}#{uri.path}#{path_query}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}#{path_query}"
      end.sub(%r{(/)+$}, '')
    end

    def get_path_query(uri:)
      uri_fragment = uri.query
      uri_fragment.nil? || (uri_fragment == '') ? nil : "?#{uri.query}"
    end

    module_function :uri, :uri!, :full_url, :get_path_query
  end
end
