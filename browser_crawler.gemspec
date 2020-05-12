# coding: utf-8
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'browser_crawler/version'

Gem::Specification.new do |spec|
  spec.name          = 'browser_crawler'
  spec.version       = BrowserCrawler::VERSION
  spec.required_ruby_version = '>= 2.5.0'
  spec.authors       = ['Dmytro Samodurov',
                        'Artem Rumiantcev',
                        'Denys Ivanchuk',
                        'Sergiy Tyatin']
  spec.email         = ['dimasamodurov@gmail.com', 'tema.place@gmail.com']
  spec.licenses      = ['MIT']

  spec.summary       = 'Simple site crawler using Capybara'
  spec.description   = ''
  spec.homepage      = 'https://github.com/DimaSamodurov/browser_crawler'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host
  # or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.2', '>= 5.2.2'
  spec.add_dependency 'capybara', '~> 3.32.1', '>= 3.32.1'
  spec.add_dependency 'chromedriver-helper', '~> 2.1', '>= 2.1.0'
  spec.add_dependency 'cuprite', '~> 0.10'

  spec.add_development_dependency 'bundler', '~> 2.1.4', '>= 2.1.4'
  spec.add_development_dependency 'pry-byebug', '~> 3.6', '>= 3.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.66'
end
