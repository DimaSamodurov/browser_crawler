$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'browser_crawler'
require 'pry'

RSpec.configure do |config|
  config.before { BrowserCrawler::HooksContainer.instance.reset }
  config.before { Capybara.current_session.quit }
  config.after  { Capybara.current_session.quit }
end
