require 'capybara'
require 'capybara-screenshot'

require_relative 'dsl/sign_in'
require_relative 'dsl/js_helpers'
require_relative 'reports/simple'
require_relative 'support/capybara'

module Crawler
  class Engine
    include Capybara::DSL
    include DSL::SignIn
    include DSL::JsHelpers

    REPORT_SAVE_PATH = 'tmp/crawl_report.yaml'.freeze
    AVAILABLE_CALLBACK_METHODS = [:before_crawling, :after_crawling].freeze

    attr_reader :report

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

      @report = Reports::Simple.new
      @report.metadata[:screenshots_path] = @screenshots_path
      @report.metadata[:window_width] = @window_width
      @report.metadata[:window_height] = @window_height
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
      @report.start(url: url)
      begin
        before_crawling

        crawl(url: url, only_path: only_path)

        after_crawling
      rescue => error
        puts error.message
      ensure
        @report.finish
      end
      self
    end

    def report_save(path: '')
      save_path = path.empty? ? REPORT_SAVE_PATH : path
      File.write(save_path, @report.to_yaml)
    end

    def before_crawling
      sign_in if ENV['username']
      sleep 5
    end

    def after_crawling
    end

    def overwrite_callback(method:, &block)
      return unless AVAILABLE_CALLBACK_METHODS.include?(method)
      return unless block_given?
      define_singleton_method(method.to_sym, block)
    end

    def visited_pages
      @report.visited_pages
    end

    private

    def get_page_links
      page.all('a').map do |a|
        href = a['href']
      end
    end

    def internal_url?(url)
      uri = URI(url.to_s)
      return true if uri.host.nil? || uri.host == @host_name
      false
    end

    def limit_reached?
      return false if @max_pages == 0
      return visited_pages.count >= @max_pages
    end

    def full_url(uri)
      if uri.port == 80 || uri.port == 443
        "#{uri.scheme}://#{uri.host}#{uri.path}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      end
    end

    def crawl(url:, only_path:)
      return "Skipped external #{url}." unless internal_url?(url)
      return 'Limit reached' if limit_reached?

      uri = URI(url.to_s)
      page_path = uri.path

      return "Skipped visited #{page_path}." if visited_pages.include?(page_path)

      puts "Visiting #{page_path}"

      visit page_path

      screenshot_filename = save_screenshot if @screenshots_path

      page_links = get_page_links

      puts "#{page_links.count} links found on the page."

      visited_page_link = only_path ? page_path : full_url(uri)
      @report.record_page_visit(page: visited_page_link,
                                extracted_links: page_links,
                                screenshot_filename: screenshot_filename)
      @report.pages[page_path] =
        {
          extracted_links: page_links,
          screenshot: screenshot_filename
        }

      unless limit_reached?
        page_links.each do |href|
          next unless internal_url?(href)
          crawl(url: href, only_path: only_path)
        end
      end
    rescue => error
      @report.record_page_visit(page: page_path, error: error.message)
      puts "Error visiting #{page_path}: #{error.message}"
    end
  end
end
