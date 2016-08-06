require 'date'
require 'yaml'
require 'kramdown'
require 'erb'

module Evander

  class Page
    attr_reader :site
    attr_reader :parent
    attr_reader :path
    attr_reader :url
    attr_reader :title
    attr_reader :date
    attr_reader :order
    attr_reader :description
    attr_reader :categories
    attr_reader :keywords
    attr_reader :sub_pages
    attr_reader :markdown
    attr_reader :should_render
    attr_reader :include_in_rss

    def initialize(site, source_path, path, parent=nil)
      @site = site
      @parent = parent
      @title = path.split('/')[-1].capitalize
      @date = nil
      @description = ""
      @categories = []
      @order = 0
      @should_render = true
      @include_in_rss = false;
      _parse_config(File.dirname(source_path))
      @keywords = @categories
      @path = path
      @url = _get_url()
      @sub_pages = []
      @markdown = File.open(source_path, "r").read
    end

    def add_sub_page(page)
      @sub_pages << page
      @sub_pages.sort!{ |left, right| left.order <=> right.order }
    end

    def render
      ERB.new(_get_template).result(binding)
    end

    def render_content
      Kramdown::Document.new(ERB.new(@markdown).result(binding), {
        :auto_ids => false, 
        :syntax_highlighter => 'rouge',
        :syntax_highlighter_opts => {
          :line_numbers => true
        }
      }).to_html
    end

    def link_to(path)
      if(path.start_with?('/'))
        full_path = path
      else
        full_path = @path + '/' + path
      end

      case full_path
      when /\.png|gif|jpg$/
        '/images' + full_path
      else
        @site.find_page(full_path).url
      end
    end

    def find_page_for_path(path)
      parts = path.split('/')
      if(parts.length > 1)
        new_path = parts.drop(1).join('/')
        return @sub_pages.select { |p| p.find_page_for_path(new_path) }.first()
      elsif @page_dir == parts[0]
        return self
      end
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
          # Order by date if there is no order specified
          if(!config.has_key?("order"))
            @order = @date.tv_sec
          end
        end
        if(config.has_key?("order"))
          @order = config["order"]
        end
        if(config.has_key?("categories"))
          @categories = config["categories"]
        end
        if(config.has_key?("render"))
          @should_render = config["render"]
        end
        if(config.has_key?("rss"))
          @include_in_rss = config["rss"]
        end
      end
    end

    def _get_url()
      page_url = @title.gsub(/[^\w\d]/, '-').gsub(/-+/, '-').downcase + ".html"
      if(@date != nil)
        page_url = @date.year.to_s + "/" + @date.month.to_s.rjust(2, "0") + "/" + @date.day.to_s.rjust(2, "0") + "/" + page_url
      end
      parts = @path.split('/')
      parts[-1] = page_url
      parts.join('/')
    end

    def _get_template()
      template_path = File::expand_path(File.dirname(__FILE__) + '/../theme/layouts/default/default.html')
      File.open(template_path).read
    end

  end

end