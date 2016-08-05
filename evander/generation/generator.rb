require 'FileUtils'

require_relative '../site.rb'

module Evander

  class Generator

    def initialize(input_dir, output_dir)
      @input_dir = input_dir
      @output_dir = output_dir
    end

    def generate()
      site = Site.new(@input_dir)
      site.render(@output_dir)
      system('compass compile --sass-dir ' + File::expand_path('./theme/layouts/default/stylesheets') + ' --css-dir ' + @output_dir + '/stylesheets')
      FileUtils.cp_r('./theme/layouts/default/images', @output_dir + '/images')
    end

  end

end