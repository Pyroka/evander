require 'pp'
require 'erb'
require 'redcarpet'
require File::expand_path('./page')

module Evander
  class Site

    def initialize(root_dir)
      @root_dir = root_dir
      @top_level_pages = Page.get_sub_pages(root_dir)
      _create_convenience_instance_vars
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true)
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

    def _create_convenience_instance_vars
      @top_level_pages.each do |page|
        if(page.is_a?(Page))
          instance_variable_set("@" + page.title, page)
        end
      end
    end

    def _render_page(page)

      parsed = ERB.new(page.markdown)
      html = @markdown.render(parsed.result(binding))
      File.write(page.filename + ".html", html)

      page.sub_pages.each do |subpage|
        if(!File.directory?(page.title))
          Dir.mkdir(page.title)
        end
        Dir.chdir(page.title) do
          _render_page(subpage)
        end
      end
    end

  end
end