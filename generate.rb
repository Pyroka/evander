require 'optparse'
require 'ostruct'
require 'pp'

module Evander

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new
      options.root_dir = ""

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: generate.rb [options]"
        opts.separator ""

        opts.on(:REQUIRED, "--root DIRECTORY", "Path to the root dir of the site") do |dir|
          options.root_dir = dir
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
  pp options
  pp ARGV

end