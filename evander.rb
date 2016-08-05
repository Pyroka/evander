require 'webrick'
require 'listen'

require_relative './evander/generation/command_line_options'
require_relative './evander/generation/watcher'
require_relative './evander/generation/generator'

module Evander

  options = CommandLineOptions.parse(ARGV)

  if(options.mode == :generate)
    puts "Generating site"
    Generator.new(options.input_dir, options.output_dir).generate()
  elsif(options.mode == :watch)
    puts "Watching for changes"
    watcher = Watcher.new(options.input_dir, options.output_dir)
    watcher.start
  end

end