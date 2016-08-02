require File::expand_path('./site')

module Evander

  class Rss

    attr_reader :site
    attr_reader :posts
    attr_reader :last_update_time

    def initialize(site, top_level_pages)
      @site = site
      @posts = _get_pages_for_rss(top_level_pages).sort { |left, right| right.date <=> left.date }
      @last_update_time = DateTime.now
    end

    def render(root_dir)
      xml = ERB.new(_get_template()).result(binding)
      File.write(root_dir + "/atom.xml", xml)
    end

    def _get_pages_for_rss(top_level_pages)
      rss_pages = []
      _get_pages_for_rss_recursive(top_level_pages, rss_pages)
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

    def _get_template()
      template_path = File::expand_path(File.dirname(__FILE__) + '/theme/_atom_template.xml')
      File.open(template_path).read
    end

  end
end