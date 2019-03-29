module BrowserCrawler
  module Reports
    # It involves methods which allow to save a store to an yaml file
    class YamlReport
      def initialize(store:)
        @store = store
      end

      def export(save_folder_path:)
        File.write("#{save_folder_path}/crawler_report.yaml",
                   @store.to_h.to_yaml)
      end
    end
  end
end
