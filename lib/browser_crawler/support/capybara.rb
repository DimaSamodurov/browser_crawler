require 'capybara'
require 'capybara/cuprite'

# Register new driver for capybara
module Capybara
  module_function

  def register_chrome_driver(name, options: {})
    unless options[:browser_options]
      options[:browser_options] = {
        '--headless' => nil, '--disable-gpu' => nil,
        '--disable-extensions' => nil, '--no-sandbox' => nil
      }
    end

    Capybara.register_driver name do |app|
      ::Capybara::Cuprite::Driver.new(app, options)
    end
  end
end
