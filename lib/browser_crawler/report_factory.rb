require 'fileutils'
require_relative 'reports/csv_report'
require_relative 'reports/yaml_report'

module BrowserCrawler
  # It saves store data to yaml or csv report file.
  module ReportFactory
    module_function

    REPORT_MATCHER = {
      yaml: Reports::YamlReport,
      csv: Reports::CsvReport
    }.freeze

    def save(store:, type:, save_folder_path:)
      FileUtils.mkdir_p(save_folder_path)
      REPORT_MATCHER[type]
        .new(store: store)
        .export(save_folder_path: save_folder_path)
    end
  end
end
