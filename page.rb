require 'date'
require 'yaml'

module Evander

  class Page

    def initialize(path)
      dirname = File.dirname(path)
      @title = dirname
      @date = DateTime.new
      @categories = []
      _parse_config(dirname)
      @sub_pages = Page.get_sub_pages(dirname)
    end

    def _parse_config(dirname)
      puts dirname
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
      pages = Hash.new
      Dir.foreach(dirname) do |child|
        Dir.chdir(dirname) do
          if(child == "." || child == ".." || !File.directory?(child))
            next
          end

          index_path = File.join(child, "index.markdown")
          if(File.exist?(index_path))
            pages[child] = Page.new(index_path)
          else
            pages[child] = Page.get_sub_pages(child)
          end
        end
      end
      pages
    end

  end

end