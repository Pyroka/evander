require 'pp'
require File::expand_path('./page')

module Evander
  class Site

    def initialize(root_dir)
      @root_dir = root_dir
      @top_level_pages = Page.get_sub_pages(root_dir)
      _create_convenience_instance_vars
      pp self
    end

    def _create_convenience_instance_vars
      @top_level_pages.each do |name, value| 
        instance_variable_set("@" + name, value)
      end
    end

  end
end