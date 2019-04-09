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

    REPORT_SAVE_FOLDER_PATH = 'tmp'.freeze
    AVAILABLE_CALLBACK_METHODS = %i[before_crawling
                                    after_crawling
                                    before_page_scan].freeze
    CUPRITE_OPTIONS = {
      window_size: [1280, 1600]
    }.freeze

    SCREENSHOT_OPERATOR_OPTIONS = {
      save_screenshots:    false,
      save_screenshots_to: nil,
      format:              'png',
      filename:            nil
    }.freeze

    attr_reader :report_store, :screenshot_operator

    def initialize(browser_options: {}, screenshots_options: {}, max_pages: nil)

      screenshots_operator_options = SCREENSHOT_OPERATOR_OPTIONS
                                       .merge(screenshots_options)
      @screenshot_operator = ScreenshotOperator.new(screenshots_operator_options)

      @max_pages = max_pages.to_i

      cuprite_options = CUPRITE_OPTIONS.merge(browser_options)

      Capybara.register_chrome_driver(:cuprite_chrome, options: cuprite_options)
      Capybara.run_server = false
      Capybara.default_driver = :cuprite_chrome
      Capybara.ignore_hidden_elements = false # a workaround to extracting data from inactive tabs, dialogs, etc.

      @report_store = Reports::Store.new
      @report_store.metadata[:screenshots_path] = screenshot_operator.screenshots_folder
      @report_store.metadata[:window_width] = @window_width
      @report_store.metadata[:window_height] = @window_height
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

    def extract_links(url:, only_path: true)
      uri = uri!(url: url)
      Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"

      @host_name = uri.host
      @report_store.start(url: url)
      begin
        before_crawling

        crawl(url: url, only_path: only_path)

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
      remove_blank_links(page.all('a').map {|a| a['href']})
    end

    def remove_blank_links(links)
      links.reject do |link|
        link.nil? || link.empty?
      end
    end

    def internal_url?(url)
      uri = uri(url: url)
      return true if uri.nil? || uri.host.nil? || uri.host == @host_name

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
      URI(url.to_s)
    rescue URI::InvalidURIError => error
      @report_store.record_unrecognized_link(url.to_s)
      puts "Skipped visited #{url}" \
           " because following error raised #{error.message}"
      raise error
    end

    def uri(url:)
      uri!(url: url)
    rescue URI::InvalidURIError
      return
    end

    def crawl(url:, only_path:)
      puts("Skipped external #{url}.") && return unless internal_url?(url)
      puts('Limit reached') && return if limit_reached?

      begin
        uri = uri!(url: url)
      rescue URI::InvalidURIError
        return
      end

      page_path = uri.path
      visited_page_link = only_path ? page_path : full_url(uri)

      if skip_visit?(visited_page_link, uri)
        @report_store.record_unrecognized_link(url.to_s)
        puts "Skipped visited #{url}."
        return
      end

      puts "Visiting #{visited_page_link}"

      visit visited_page_link

      before_page_scan

      page_links = get_page_links

      puts "#{page_links.count} links found on the page."

      if screenshot_operator.save_screenshots?
        screenshot_path = page.save_screenshot(
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

      unless limit_reached?
        page_links.each do |href|
          next unless internal_url?(href)

          crawl(url: href, only_path: only_path)
          break if limit_reached?
        end
      end
    rescue StandardError => error
      @report_store.record_page_visit(page: visited_page_link, error: error.message)
      puts "Error visiting #{visited_page_link}: #{error.message}"
    end
  end
end
