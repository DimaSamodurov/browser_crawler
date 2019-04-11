require 'capybara'
require 'capybara/dsl'

require_relative 'dsl/sign_in'
require_relative 'dsl/js_helpers'
require_relative 'report_factory'
require_relative 'reports/store'
require_relative 'support/capybara'
require_relative 'screenshot_operator'

module BrowserCrawler
  class Engine
    include Capybara::DSL
    include DSL::SignIn
    include DSL::JsHelpers

    class UnavailableCallBackMethod < StandardError;
    end

    REPORT_SAVE_FOLDER_PATH    = 'tmp'.freeze
    AVAILABLE_CALLBACK_METHODS = %i[before_crawling
                                    after_crawling
                                    before_page_scan].freeze
    CUPRITE_OPTIONS            = {
      window_size: [1280, 1600]
    }.freeze

    SCREENSHOT_OPERATOR_OPTIONS = {
      save_screenshots:    false,
      save_screenshots_to: nil,
      format:              'png',
      filename:            nil
    }.freeze

    attr_reader :report_store, :screenshot_operator, :deep_visit

    def initialize(browser_options: {},
                   screenshots_options: {},
                   max_pages: nil,
                   deep_visit: false)

      screenshots_operator_options = SCREENSHOT_OPERATOR_OPTIONS
                                       .merge(screenshots_options)
      @screenshot_operator         = ScreenshotOperator.new(screenshots_operator_options)

      @max_pages  = max_pages.to_i
      @deep_visit = deep_visit

      cuprite_options = CUPRITE_OPTIONS.merge(browser_options)

      Capybara.register_chrome_driver(:cuprite_chrome, options: cuprite_options)
      Capybara.run_server             = false
      Capybara.default_driver         = :cuprite_chrome
      Capybara.ignore_hidden_elements = false # a workaround to extracting data from inactive tabs, dialogs, etc.

      @report_store                             = Reports::Store.new
      @report_store.metadata[:screenshots_path] = screenshot_operator.screenshots_folder
      @report_store.metadata[:window_width]     = cuprite_options[:window_size][0]
      @report_store.metadata[:window_height]    = cuprite_options[:window_size][1]
    end

    def js_before_run(javascript: '')
      unless javascript.empty?
        Capybara.current_session
          .driver
          .browser
          .page
          .command('Page.addScriptToEvaluateOnNewDocument',
                   source: javascript)
      end
    end

    def extract_links(url:)
      uri               = uri!(url: url)
      Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"

      @host_name = uri.host
      @report_store.start(url: url)
      begin
        before_crawling

        crawl(url: url)

        after_crawling
      rescue StandardError => error
        puts error.message
      ensure
        @report_store.finish
      end
      self
    end

    def report_save(folder_path: '', type: :yaml)
      save_folder_path = folder_path.empty? ? REPORT_SAVE_FOLDER_PATH : folder_path
      ReportFactory.save(store: @report_store, type: type.to_sym, save_folder_path: save_folder_path)
    end

    def before_crawling
      sign_in if ENV['username']
      sleep 5
    end

    def after_crawling;
    end

    def before_page_scan;
    end

    def overwrite_callback(method:, &block)
      unless AVAILABLE_CALLBACK_METHODS.include?(method)
        raise UnavailableCallBackMethod.new('Overwrite unavailable' \
                                            " callback method: #{method}")
      end
      return unless block_given?

      define_singleton_method(method.to_sym, block)
    end

    def visited_pages
      @report_store.visited_pages
    end

    private

    def get_page_links
      remove_blank_links(page.all('a').map { |a| a['href'] })
    end

    def remove_blank_links(links)
      links.reject do |link|
        link.nil? || link.empty?
      end
    end

    def internal_url?(url)
      uri = uri(url: url)
      return true if (uri&.host && uri.host == @host_name)

      false
    end

    def limit_reached?
      return false if @max_pages.zero?

      visited_pages.count >= @max_pages
    end

    def full_url(uri)
      if uri.port == 80 || uri.port == 443
        "#{uri.scheme}://#{uri.host}#{uri.path}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      end
    end

    def skip_visit?(visited_page_link, uri)
      visited_pages.include?(visited_page_link) ||
        uri.host.nil? ||
        uri.scheme.nil?
    end

    def uri!(url:)
      string_url = url.to_s
      unless string_url =~ /\A#{URI::regexp(%w(http https))}\z/
        raise URI::InvalidURIError
      end
      URI(string_url)
    rescue URI::InvalidURIError => error
      unless @report_store.unrecognized_links.include?(string_url)
        @report_store.record_unrecognized_link(string_url)
      end
      puts "Skipped visited #{url}" \
           " because following error raised #{error.message}"
      raise error
    end

    def uri(url:)
      uri!(url: url)
    rescue URI::InvalidURIError
      return
    end

    def skip_external_resource?(url)
      !internal_url?(url) && !deep_visit
    end

    def crawl(url:)
      if skip_external_resource?(url)
        puts("Skipped external #{url}.")
        return
      end

      puts('Limit reached') && return if limit_reached?

      uri = uri(url: url)
      return if uri.nil?

      page_path         = uri.path
      visited_page_link = full_url(uri)

      if skip_visit?(visited_page_link, uri)
        puts "Skipped visited #{url}."
        return
      end

      puts "Visiting #{visited_page_link}"

      unless internal_url?(url)
        Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end

      visit visited_page_link

      before_page_scan

      page_links = internal_url?(url) ? get_page_links : []

      puts "#{page_links.count} links found on the page."

      screenshot_path = if screenshot_operator.save_screenshots?
                          page.save_screenshot(
                            screenshot_operator.file_path(url: page_path)
                          )
                        end

      @report_store.record_page_visit(
        page:                visited_page_link,
        extracted_links:     page_links,
        screenshot_filename: screenshot_path,
        external:            !internal_url?(url),
        code:                page.status_code
      )

      return unless internal_url?(url)

      visit_links_on_page(page_links)
    rescue StandardError => error
      @report_store.record_page_visit(page: visited_page_link, error: error.message)
      puts "Error visiting #{visited_page_link}: #{error.message}"
    end

    def visit_links_on_page(page_links)
      unless limit_reached?
        page_links.each do |href|
          next if uri(url: href).nil? && skip_external_resource?(href)
          crawl(url: href)
          break if limit_reached?
        end
      end
    end
  end
end
