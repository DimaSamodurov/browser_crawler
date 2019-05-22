module BrowserCrawler
  module UrlTools
    def uri(url:)
      uri!(url: url)
    rescue URI::InvalidURIError
      return
    end

    def uri!(url:)
      string_url = url.to_s
      unless string_url =~ /\A#{URI::regexp(%w(http https))}\z/
        raise URI::InvalidURIError
      end
      URI(string_url)
    end

    def full_url(uri:)
      if uri.port == 80 || uri.port == 443
        "#{uri.scheme}://#{uri.host}#{uri.path}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      end.sub(/(\/)+$/,'')
    end

    module_function :uri, :uri!, :full_url
  end
end