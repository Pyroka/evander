require 'optparse'
require 'ostruct'
require File::expand_path('./site')

module Evander

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new
      options.input_dir = ""

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: generate.rb [options]"
        opts.separator ""

        opts.on("--input DIRECTORY", "Path to the root input dir of the site") do |dir|
          options.input_dir = dir
        end

        opts.on("--output DIRECTORY", "Path to the output input dir of the site") do |dir|
          options.output_dir = dir
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

      end

      opt_parser.parse!(args)
      options
    end

  end

  options = CommandLineOptions.parse(ARGV)

  site = Site.new(options.input_dir)
  site.render(options.output_dir)

end