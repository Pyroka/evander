require_relative './site'

module Evander

  class Rss

    attr_reader :site
    attr_reader :posts
    attr_reader :last_update_time

    def initialize(site, all_pages)
      @site = site
      @posts = all_pages.select{ |page| page.include_in_rss }.sort { |left, right| right.date <=> left.date }
      @last_update_time = DateTime.now 
    end

    def render(root_dir)
      xml = ERB.new(_get_template()).result(binding)
      File.write(root_dir + "/atom.xml", xml)
    end

    def _get_template()
      template_path = File::expand_path(File.dirname(__FILE__) + '/../theme/_atom_template.xml')
      File.open(template_path).read
    end

  end
end