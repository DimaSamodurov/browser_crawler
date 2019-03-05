require 'dsl_organizer'
require "crawler/version"
require 'capybara'

require 'crawler/dsl/configuration'
require 'crawler/dsl/hooks/after_hook'
require 'crawler/dsl/hooks/before_hook'
require 'crawler/dsl/link_extractor'
require 'crawler/dsl/visit_command'
require 'crawler/options'
require 'crawler/hooks_operator'
require 'crawler/engine'

require 'crawler/followups/screenshots_indexer'
require 'crawler/followups/wraith_integrator'

# Crawls web site and extracts links available.

module Crawler
  include DslOrganizer.dictionary(commands: [
      :after,
      :before,
      :configuration,
      :extract_links_for,
      :visit_to
  ])
end
