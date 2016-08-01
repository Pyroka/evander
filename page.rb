require 'date'
require 'yaml'
require 'kramdown'
require 'erb'

module Evander

  class Page
    attr_reader :site
    attr_reader :url
    attr_reader :relative_url
    attr_reader :title
    attr_reader :date
    attr_reader :description
    attr_reader :categories
    attr_reader :keywords
    attr_reader :filename
    attr_reader :sub_pages
    attr_reader :markdown

    def initialize(site, path)
      dirname = File.dirname(path)
      @site = site
      @title = dirname
      @date = Time.new
      @description = ""
      @categories = []
      _parse_config(dirname)
      @keywords = @categories
      @filename = _get_filename()
      @relative_url = @filename
      @url = site.url + "/" + @relative_url
      @sub_pages = Page.get_sub_pages(site, dirname)
      @markdown = File.open(path, "r").read
    end

    def self.get_sub_pages(site, dirname)
      pages = []
      Dir.foreach(dirname) do |child|
        Dir.chdir(dirname) do
          if(child == "." || child == ".." || !File.directory?(child))
            next
          end

          index_path = File.join(child, "index.markdown")
          if(File.exist?(index_path))
            pages << Page.new(site, index_path)
          else
            pages.push(*Page.get_sub_pages(site, child))
          end
        end
      end
      pages
    end

    def render
      ERB.new(_get_template).result(binding)
    end

    def render_content
      Kramdown::Document.new(ERB.new(@markdown).result(binding), :auto_ids => false).to_html
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

    def _get_filename()
      page_filename = @title.gsub(/[^\w\d]/, '-').gsub(/-+/, '-').downcase + ".html"
      if(@date != Time.new)
        page_filename = @date.year.to_s + "/" + @date.month.to_s.rjust(2, "0") + "/" + @date.day.to_s.rjust(2, "0") + "/" + page_filename
      end
      page_filename
    end

    def _get_template()
      template_path = File::expand_path(File.dirname(__FILE__) + '/theme/layouts/default.html')
      File.open(template_path).read
    end

  end

end