require 'date'
require 'yaml'

module Evander

  class Page
    attr_reader :title
    attr_reader :date
    attr_reader :categories
    attr_reader :filename
    attr_reader :sub_pages
    attr_reader :markdown

    def initialize(path)
      dirname = File.dirname(path)
      @title = dirname
      @date = DateTime.new
      @categories = []
      _parse_config(dirname)
      @filename = @title.gsub(':', '-').gsub(' ', '-')
      @sub_pages = Page.get_sub_pages(dirname)
      @markdown = File.open(path, "r").read
    end

    def _parse_config(dirname)
      config_path = dirname + "/config.yaml";
      if(File.exist?(config_path))
        config = YAML.load_file(config_path)
        if(config.has_key?("title"))
          @title = config["title"]
        end
        if(config.has_key?("date"))
          @date = config["date"]
        end
        if(config.has_key?("categories"))
          @categories = config["categories"]
        end
      end
    end

    def self.get_sub_pages(dirname)
      pages = []
      Dir.foreach(dirname) do |child|
        Dir.chdir(dirname) do
          if(child == "." || child == ".." || !File.directory?(child))
            next
          end

          index_path = File.join(child, "index.markdown")
          if(File.exist?(index_path))
            pages << Page.new(index_path)
          else
            pages << Page.get_sub_pages(child)
          end
        end
      end
      pages
    end

  end

end