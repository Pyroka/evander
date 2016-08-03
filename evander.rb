require 'webrick'
require 'listen'

require_relative './evander/generation/command_line_options'
require_relative './evander/generation/watcher'
require_relative './evander/site'

module Evander

  options = CommandLineOptions.parse(ARGV)

  if(options.mode == :generate)
    puts "Generating site"
    site = Site.new(options.input_dir)
    site.render(options.output_dir)
  elsif(options.mode == :watch)
    puts "Watching for changes"
    watcher = Watcher.new(options.input_dir, options.output_dir, File::expand_path('.'))
    watcher.start
  end

end