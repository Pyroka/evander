require 'optparse'
require 'ostruct'
require 'webrick'
require 'listen'

require File::expand_path('./site')

module Evander

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new
      options.input_dir = ""
      options.mode = :generate

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: generate.rb [options]"
        opts.separator ""

        opts.on("--mode [MODE]", [:watch, :generate], "Select mode") do |mode|
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
      options
    end

  end

  class NonCachingFileHandler < WEBrick::HTTPServlet::FileHandler
    def prevent_caching(res)
      res['ETag']          = nil
      res['Last-Modified'] = Time.now + 100**4
      res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
      res['Pragma']        = 'no-cache'
      res['Expires']       = Time.now - 100**4
    end
    
    def do_GET(req, res)
      super
      prevent_caching(res)
    end
  end

  options = CommandLineOptions.parse(ARGV)

  if(options.mode == :generate)
    puts "Generating site"
    site = Site.new(options.input_dir)
    site.render(options.output_dir)
  elsif(options.mode == :watch)
    puts "Watching for changes"

    server = WEBrick::HTTPServer.new(:Port => 8000)
    server.mount('/', NonCachingFileHandler, options.output_dir)
    trap 'INT' do 
      server.shutdown 
    end

    listener = Listen.to(options.input_dir) do |modified, added, removed|
      site = Site.new(options.input_dir)
      site.render(options.output_dir)
    end
    listener.start

    server.start
  end

end