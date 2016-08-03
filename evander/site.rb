require 'yaml'
require 'fileutils'

require_relative './page'
require_relative './extensions'
require_relative './rss'

module Evander

  class Site

    def initialize(root_dir)
      _parse_config(root_dir)
      @root_dir = root_dir
      @top_level_pages = Page.get_sub_pages(self, root_dir)
      @rss = Rss.new(self, @top_level_pages)
    end

    def render(root_dir)
      if(!File.directory?(root_dir))
        Dir.mkdir(root_dir)
      else
        FileUtils.rm_rf(Dir.glob(root_dir + "/*"))
      end
      Dir.chdir(root_dir) do
        @top_level_pages.each do |page|
          _render_page(page)
        end
      end
      @rss.render(root_dir)
    end

    def _render_page(page)
      if(!page.should_render)
        return
      end
      html = page.render
      page_dir = File.dirname(page.relative_url)
      if(!File.directory?(page_dir))
        FileUtils.mkdir_p(page_dir)
      end
      File.write(page.relative_url, html)
      page.sub_pages.each do |subpage|
        _render_page(subpage)
      end
    end

    def _parse_config(dirname)
      config_path = dirname + "/config.yaml";
      if(File.exist?(config_path))
        config = YAML.load_file(config_path)
        config.each do |key, value|
          instance_variable_set("@" + key, value)
          self.class.send(:attr_reader, key)
        end
      end
    end

    def _get_pages_for_rss()
      rss_pages = []
      _get_pages_for_rss_recursive(@top_level_pages, rss_pages)
      rss_pages
    end

    def _get_pages_for_rss_recursive(all_pages, pages_to_include)
      all_pages.each do |page|
        if(page.include_in_rss)
          pages_to_include << page
        end
        _get_pages_for_rss_recursive(page.sub_pages, pages_to_include)
      end
    end

  end
end