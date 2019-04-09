module BrowserCrawler
  # Control operations on screenshots
  class ScreenshotOperator
    attr_reader :format, :save_screenshots, :filename_base, :screenshots_folder

    def initialize(save_screenshots: false,
                   save_screenshots_to: nil,
                   format: 'png',
                   filename: nil)
      @screenshots_folder = save_screenshots_to
      @format = format
      @save_screenshots = save_screenshots
      @filename_base = filename || 'screenshot'
    end

    def save_screenshots?
      [screenshots_folder, save_screenshots].any?
    end

    def file_path(url: nil)
      "#{save_path}/#{filename(url: url)}"
    end

    def filename(url: nil)
      if !filename_base_default? || url.nil?
        "#{filename_prefix}_#{filename_base}.#{format}"
      else
        "#{filename_prefix}_#{url}.#{format}"
      end
    end

    private

    def filename_base_default?
      filename_base == 'screenshot'
    end

    def save_path
      screenshots_folder || File.join(Dir.pwd, 'tmp', 'screenshots')
    end

    def filename_prefix
      Time.now.getutc.to_s.tr(' ', '_')
    end
  end
end
