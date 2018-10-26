require 'capybara'
require 'selenium/webdriver'

module Capybara

  module_function

  def register_chrome_driver(name, window_width: 1280, window_height: 1600)
    Capybara.register_driver name do |app|
      options = ::Selenium::WebDriver::Chrome::Options.new
      options.add_preference(:download, prompt_for_download: false,
                             default_directory: File.join(Dir.pwd, 'tmp', 'screenshots'))

      options.add_preference(:browser, set_download_behavior: {behavior: 'allow'})
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      options.add_argument("--window-size=#{window_width},#{window_height}")

      driver = ::Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)

      ### Allow file downloads in Google Chrome when headless!!!
      ### https://bugs.chromium.org/p/chromium/issues/detail?id=696481#c89
      bridge = driver.browser.send(:bridge)

      path = '/session/:session_id/chromium/send_command'
      path[':session_id'] = bridge.session_id

      bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior',
                       params: {
                           behavior: 'allow',
                           downloadPath: File.join(Dir.pwd, 'tmp', 'downloads')
                       })
      ###

      driver
    end
  end
end
