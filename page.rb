require 'date'
require 'yaml'
require 'kramdown'

module Evander

  class Page
    attr_reader :url
    attr_reader :relative_url
    attr_reader :title
    attr_reader :date
    attr_reader :categories
    attr_reader :filename
    attr_reader :sub_pages
    attr_reader :markdown

    def initialize(site, path)
      dirname = File.dirname(path)
      @title = dirname
      @date = DateTime.new
      @categories = []
      _parse_config(dirname)
      @filename = @title.gsub(':', '-').gsub(' ', '-').downcase
      @relative_url = @filename + ".html"
      @url = site.url + "/" + @relative_url
      @sub_pages = Page.get_sub_pages(site, dirname)
      @markdown = File.open(path, "r").read
    end

    def create_context(parent_context)
      @context = parent_context.clone
      @context.url = @url
      @context.title = @title
      @context.date = @date
      @context.categories = @categories
      @context.keywords = @categories
      @context.filename = @filename
      @context.sub_pages = @sub_pages
      @context.markdown = @markdown
      @sub_pages.each do |page|
        page.create_context(parent_context)
      end
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
      @context.render(_get_template)
    end

    def render_content
      Kramdown::Document.new(@context.render(@markdown), :auto_ids => false).to_html
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

    def _get_template()
      template_path = File::expand_path(File.dirname(__FILE__) + '/theme/layouts/default.html')
      File.open(template_path).read
    end

  end

end