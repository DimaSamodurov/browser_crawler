require 'optionparser'

module BrowserCrawler
  module Options
    module_function

    def default_options
      {
        report_folder: 'tmp',
        report_format: 'yaml',
        window_width: 1024,
        window_height: 768
      }
    end

    def parse_args
      options = {}
      p = OptionParser.new do |opts|
        opts.on_tail

        opts.banner = 'Site crawler. Usage example: crawl http://localhost:3000'

        opts.on('-U', '[--url] URL', 'Crawls the site starting from the url specified. E.g. http://localhost:3000/welcome.') do |v|
          options[:url] = v
        end

        opts.on('-u', '--user USERNAME', 'The authentication user name (optional).') do |v|
          options[:username] = v
        end

        opts.on('-p', '--password PASSWORD', 'The authentication password (optional).') do |v|
          options[:password] = v
        end

        opts.on('-n', '--max_pages NUM', 'The maximum number of pages to visit.') do |v|
          options[:max_pages] = v.to_i
        end

        opts.on('-w', '--window_size WxH', 'Browser window size. Default 1024x768') do |v|
          options[:window_width], options[:window_height] = v.split('x')
        end

        opts.on('-r', '--report FOLDER', 'The folder path to save report to. '\
                                         'Default: tmp') do |v|
          options[:report_folder] = v
        end

        opts.on('-f', '--report_format TYPE', 'The report type to save result  '\
                                         'Default: yaml') do |v|
          options[:report_format] = v
        end

        opts.on('-s', '--screenshots_path PATH',
                'If specified along with the url, screenshots are captured visiting each page.'\
                ' Otherwise used to generate a screenshots index based on files caprured previously. ') do |v|
          options[:screenshots_path] = v
        end

        opts.on('-t', '--template FILENAME',
                'Specify the template used for indexing.'\
                '  Default: followups/templates/index.html.erb') do |v|
          options[:index_template] = v
        end

        opts.on('-c', '--wraith_config FILENAME',
                'Update config "paths" section with the pages extracted.') do |v|
          options[:wraith_config] = v
        end

        opts.on('-h', '--help', 'Show this help message and exit.') do
          puts opts
        end
      end
      p.parse!

      options[:url] = ARGV.pop unless ARGV.empty?

      if options.empty?
        puts p
        exit
      end

      default_options.merge(options)
    end
  end
end
