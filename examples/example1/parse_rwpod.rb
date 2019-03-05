require_relative '../../lib/crawler'

Crawler.run do
  configuration do |conf|
    conf.max_pages 10
  end

  before :all do
    visit_to 'https://www.epam.com/'
    within('.top-navigation-ui') do
      click_on 'Careers'
    end
    page.find('h2' ,text:'Find your dream job')
  end

  extract_links_for('https://www.rwpod.com/')
end
