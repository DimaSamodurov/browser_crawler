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
      if uri.port == 80 || uri.port == 443
        "#{uri.scheme}://#{uri.host}#{uri.path}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      end.sub(%r{(/)+$}, '')
    end

    module_function :uri, :uri!, :full_url
  end
end
