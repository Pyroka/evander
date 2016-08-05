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
      _copy_source_images()
    end

    def _copy_source_images()
      Dir.glob(@input_dir + "/**/*.{png,gif,jpg}").each do |path|
        relative_from_input = path.sub(@input_dir, '')
        output_path = @output_dir + "/images" + relative_from_input
        img_dir = File.dirname(output_path)
        if(!File.directory?(img_dir))
          FileUtils.mkdir_p(img_dir)
        end
        FileUtils.cp(path, output_path)
      end
    end

  end

end