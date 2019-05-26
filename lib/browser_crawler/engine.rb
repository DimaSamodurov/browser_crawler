require 'capybara'
require 'capybara/dsl'
require 'logger'

require_relative 'dsl/sign_in'
require_relative 'dsl/js_helpers'
require_relative 'report_factory'
require_relative 'reports/store'
require_relative 'support/capybara'
require_relative 'screenshot_operator'
require_relative 'url_tools'
require_relative 'engine_utilities/crawl_manager'
require_relative 'hooks_operator'
require_relative 'hooks_container'

module BrowserCrawler
  class Engine
    include Capybara::DSL
    include HooksOperator
    include DSL::SignIn
    include DSL::JsHelpers

    class UnavailableCallBackMethod < StandardError
    end

    REPORT_SAVE_FOLDER_PATH    = 'tmp'.freeze

    CUPRITE_OPTIONS            = {
      window_size: [1280, 1600]
    }.freeze

    SCREENSHOT_OPERATOR_OPTIONS = {
      save_screenshots: false,
      save_screenshots_to: nil,
      format: 'png',
      filename: nil
    }.freeze

    attr_reader :report_store,
                :screenshot_operator,
                :crawl_manager,
                :logger

    def initialize(browser_options: {},
                   screenshots_options: {},
                   max_pages: nil,
                   deep_visit: false,
                   logger: nil)
      screenshots_operator_options = SCREENSHOT_OPERATOR_OPTIONS
                                     .merge(screenshots_options)
      @screenshot_operator = ScreenshotOperator.new(screenshots_operator_options)

      cuprite_options = CUPRITE_OPTIONS.merge(browser_options)

      @logger = logger || Logger.new(STDOUT)

      register_chrome_driver(cuprite_options)
      initialize_report_store(cuprite_options)
      initialize_crawl_manager(max_pages, deep_visit)
    end

    def js_before_run(javascript: '')
      return if javascript.empty?

      @javascript_before_run = javascript
    end

    def extract_links(url:)
      initialize_crawler(url)

      begin
        with_hooks_for(type: :all) do
          crawl_manager.crawl(
            target_url: url,
            capybara_session: Capybara.current_session,
            screenshot_operator: screenshot_operator
          )
        end
      rescue StandardError => error
        logger
          .fatal("#{error.message} \n #{error.backtrace.join("\n")}")
      ensure
        @report_store.finish
      end
      self
    end

    def report_save(folder_path: '', type: :yaml)
      save_folder_path = folder_path.empty? ? REPORT_SAVE_FOLDER_PATH : folder_path
      ReportFactory.save(store: @report_store,
                         type: type.to_sym,
                         save_folder_path: save_folder_path)
    end

    def before(type: :all, &hook)
      HooksContainer.instance.add_hook(method: :before, type: type, hook: hook)
    end

    def after(type: :all, &hook)
      HooksContainer.instance.add_hook(method: :after, type: type, hook: hook)
    end

    private

    def initialize_crawler(url)
      Capybara.current_session.quit

      uri               = UrlTools.uri!(url: url)
      Capybara.app_host = "#{uri.scheme}://#{uri.host}:#{uri.port}"

      @report_store.start(url: url)

      return if  @javascript_before_run.nil?

      Capybara.current_session
        .driver
        .browser
        .page
        .command('Page.addScriptToEvaluateOnNewDocument',
                 source: @javascript_before_run)
    end

    def initialize_report_store(cuprite_options)
      @report_store = Reports::Store.new
      @report_store.metadata[:screenshots_path] = screenshot_operator
                                                  .screenshots_folder
      @report_store.metadata[:window_width] = cuprite_options[:window_size][0]
      @report_store.metadata[:window_height] = cuprite_options[:window_size][1]
    end

    def register_chrome_driver(cuprite_options)
      Capybara.register_chrome_driver(:cuprite_chrome, options: cuprite_options)
      Capybara.run_server             = false
      Capybara.default_driver         = :cuprite_chrome
      # a workaround to extracting data from inactive tabs, dialogs, etc.
      Capybara.ignore_hidden_elements = false
    end

    def initialize_crawl_manager(max_pages, deep_visit)
      @crawl_manager = EngineUtilities::CrawlManager.new(
        report_store: report_store,
        max_pages: max_pages.to_i,
        deep_visit: deep_visit,
        logger: @logger
      )
    end
  end
end
