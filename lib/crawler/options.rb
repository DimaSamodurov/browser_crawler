require 'optionparser'

module Crawler
  module Options

    module_function

    def default_options
      {
        output: 'tmp/crawl_report.yml',
        window_width: 1024,
        window_height: 768
      }
    end

    def parse_args
      options = {}
      p = OptionParser.new do |opts|
        opts.on_tail

        opts.banner = "Site crawler. Usage example: crawl http://localhost:3000"

        opts.on('-U', '[--url] URL', 'The url to crawl. E.g. http://localhost:3000/welcome. Required.') do |v|
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

        opts.on('-o', '--output FILE', 'The file path to save report to. '\
                                         'Default: tmp/crawl_report.yml') do |v|
          options[:output]
        end

        opts.on('-s', '--screenshots PATH', 'If specified, screenshots are created '\
                  'visiting each page and saved to the folder specified.') do |v|
          options[:screenshots_path] = v
        end

        opts.on('-h', '--help', 'Show this help message and exit.') do | |
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
