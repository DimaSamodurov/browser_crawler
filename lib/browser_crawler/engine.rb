require 'capybara'
require 'capybara-screenshot'

require_relative 'dsl/sign_in'
require_relative 'dsl/js_helpers'
require_relative 'report_factory'
require_relative 'reports/store'
require_relative 'support/capybara'

module BrowserCrawler
  class Engine
    include Capybara::DSL
    include DSL::SignIn
    include DSL::JsHelpers

    REPORT_SAVE_FOLDER_PATH = 'tmp'.freeze
    AVAILABLE_CALLBACK_METHODS = %i[before_crawling after_crawling].freeze

    attr_reader :report_store

    def initialize(save_screenshots_to: nil, max_pages: nil,
                   window_width: 1280, window_height: 1600)

      @screenshots_path = save_screenshots_to
      @max_pages = max_pages.to_i
      @window_width = window_width.to_i
      @window_height = window_height.to_i

      Capybara.register_chrome_driver(:headless_chrome,
                                      window_width: @window_width, window_height: @window_height)
      Capybara.save_path = @screenshots_path
      Capybara.run_server = false
      Capybara.default_driver = :headless_chrome
      Capybara.ignore_hidden_elements = false # a workaround to extracting data from inactive tabs, dialogs, etc.

      @report_store = Reports::Store.new
      @report_store.metadata[:screenshots_path] = @screenshots_path
      @report_store.metadata[:window_width] = @window_width
      @report_store.metadata[:window_height] = @window_height
    end

    def js_before_run(javascript: '')
      unless javascript.empty?
        params = {
          cmd: 'Page.addScriptToEvaluateOnNewDocument',
          params: {
            source: javascript
          }
        }
        Capybara.current_session.driver.browser.send(:bridge).send_command(params)
      end
    end

    def extract_links(url:, only_path: true)
      uri = URI(url.to_s)
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

    def after_crawling; end

    def overwrite_callback(method:, &block)
      return unless AVAILABLE_CALLBACK_METHODS.include?(method)
      return unless block_given?

      define_singleton_method(method.to_sym, block)
    end

    def visited_pages
      @report_store.visited_pages
    end

    private

    def get_page_links
      page.all('a').map do |a|
        a['href']
      end
    end

    def internal_url?(url)
      uri = URI(url.to_s)
      return true if uri.host.nil? || uri.host == @host_name

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

    def crawl(url:, only_path:)
      puts("Skipped external #{url}.") && return unless internal_url?(url)
      puts('Limit reached') && return if limit_reached?

      begin
        uri = URI(url.to_s)
        page_path = uri.path
        visited_page_link = only_path ? page_path : full_url(uri)
      rescue URI::InvalidURIError => error
        @report_store.record_unrecognized_link(url.to_s)
        puts "Skipped visited #{url}" \
             " because following error raised #{error.message}"
        return
      end

      if skip_visit?(visited_page_link, uri)
        @report_store.record_unrecognized_link(url.to_s)
        puts "Skipped visited #{url}."
        return
      end

      puts "Visiting #{visited_page_link}"

      visit visited_page_link

      screenshot_filename = save_screenshot if @screenshots_path

      page_links = get_page_links

      puts "#{page_links.count} links found on the page."

      @report_store.record_page_visit(page: visited_page_link,
                                      extracted_links: page_links,
                                      screenshot_filename: screenshot_filename)
      @report_store.pages[visited_page_link] = {
        extracted_links: page_links,
        screenshot: screenshot_filename
      }

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
