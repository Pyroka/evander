require 'yaml'
require 'fileutils'

require_relative './page'
require_relative './extensions'
require_relative './rss'

module Evander

  class Site

    attr_reader :top_level_pages

    def initialize(root_dir)
      _parse_config(root_dir)
      @root_dir = root_dir
      @all_pages = []
      @top_level_pages = []
      _get_all_pages(root_dir)
      @top_level_pages.sort!{ |left, right| left.order <=> right.order }
      @top_level_pages.each_index do |i|
        @top_level_pages[i].prev_page = @top_level_pages[i - 1]
        @top_level_pages[i].next_page = @top_level_pages[i + 1]
      end
      @rss = Rss.new(self, @all_pages)
    end

    def render(root_dir)
      if(!File.directory?(root_dir))
        Dir.mkdir(root_dir)
      else
        FileUtils.rm_rf(Dir.glob(root_dir + "/*"))
      end
      @all_pages.each do | page |
        _render_page(root_dir, page)
      end
      @rss.render(root_dir)
    end

    def find_page(path)
      @all_pages.select{ |page| page.path == path }.first
    end

    def _get_all_pages(root_dir)
      all_page_paths = Dir.glob(root_dir + "/**/index.markdown").map{ |path| path.sub(root_dir, '')}
      page_path_parts = all_page_paths.map{ |path| path.split('/') }.sort{ |left, right| left.length <=> right.length }
      page_path_parts.each do |parts|
        parent_page = nil
        # Last part is the index.markdown, and we don't usually need that
        path_parts = parts.take(parts.length - 1)
        if(path_parts.length > 1)
          parent_page = find_page(path_parts.take(path_parts.length - 1).join('/'))
        end
        page = Page.new(self, root_dir + parts.join('/'), path_parts.join('/'), parent_page)
        if(parent_page.nil?)
          @top_level_pages << page
        else
          parent_page.add_sub_page(page)
        end
        @all_pages << page
      end
    end

    def _render_page(root_dir, page)
      if(!page.should_render)
        return
      end
      html = page.render
      full_path = File.join(root_dir, page.url).sub(/\/{2,}/, '/')
      page_dir = File.dirname(full_path)
      if(!File.directory?(page_dir))
        FileUtils.mkdir_p(page_dir)
      end
      File.write(full_path, html)
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