require 'spec_helper'
require 'browser_crawler/followups/wraith_integrator'

describe BrowserCrawler::Followups::WraithIntegrator do
  describe '#pages_list' do
    it 'extracts visited pages from the crawl_report.yml' do
      yml = <<-YAML
---
pages:
  "/":
    :status_code: 200
    :screenshot: "tmp/screenshots/capybara-201611281615324127689252.png"
    :extracted_links:
    - http://localhost:3000/helpdesks
    - http://some.external.com/sites/sa/en-us/pages1.html
    - http://localhost:3000/
  "/helpdesks":
    :status_code: 200
    :screenshot: "tmp/screenshots/capybara-201611281615324127689253.png"
    :extracted_links:
    - http://localhost:3000/helpdesks
    - http://localhost:3000/
YAML

      expected = {
        '' => '/',
        'helpdesks' =>'/helpdesks'
      }

      cfg = BrowserCrawler::Followups::WraithIntegrator.new(report: yml)
      expect(cfg.paths).to eql expected
    end
  end
end
