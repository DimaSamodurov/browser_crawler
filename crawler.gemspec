# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crawler/version'

Gem::Specification.new do |spec|
  spec.name          = "crawler"
  spec.version       = Crawler::VERSION
  spec.authors       = ["Dmytro Samodurov"]
  spec.email         = ["dimasamodurov@gmail.com"]

  spec.summary       = %q{Simple site crawler using Capybara and Phantomjs}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/DimaSamodurov/crawler"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara", "~> 2.10"
  spec.add_dependency "capybara-screenshot"
  spec.add_dependency "activesupport"
  spec.add_dependency "chromedriver-helper", '~> 2.1'
  spec.add_dependency "selenium-webdriver"


  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug"
end
