require 'optparse'
require 'ostruct'

module Evander

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new
      options.input_dir = ""
      options.mode = :generate
      options.params = []

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: generate.rb [options]"
        opts.separator ""

        opts.on("--mode [MODE]", [:watch, :generate, :new_post], "Select mode") do |mode|
          options.mode = mode
        end

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

      args.each do |param|
        options.params << param
      end
      
      options
    end

  end
end