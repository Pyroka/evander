require 'yaml'
require 'pp'
require File::expand_path('./page')
require File::expand_path('./erb_context')

module Evander

  class Site

    attr_reader :rss_url

    def initialize(root_dir)
      _parse_config(root_dir)
      @root_dir = root_dir
      @rss_url = ""
      @top_level_pages = Page.get_sub_pages(self, root_dir)
      site_context = _create_site_context
      @top_level_pages.each do |page|
        page.create_context(site_context)
      end
    end

    def render(root_dir)
      if(!File.directory?(root_dir))
        Dir.mkdir(root_dir)
      end
      Dir.chdir(root_dir) do
        @top_level_pages.each do |page|
          if(page.is_a?(Page))
            _render_page(page)
          end
        end
      end
    end

    def _create_site_context
      temp_hash = Hash.new
      @top_level_pages.each do |page|
        if(page.is_a?(Page))
          temp_hash[page.title] = page
        end
      end
      temp_hash["site"] = self
      ErbContext.new(temp_hash)
    end

    def _render_page(page)
      html = page.render
      File.write(page.relative_url, html)
      page.sub_pages.each do |subpage|
        if(!File.directory?(page.title))
          Dir.mkdir(page.title)
        end
        Dir.chdir(page.title) do
          _render_page(subpage)
        end
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

  end
end