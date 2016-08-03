require 'webrick'
require 'listen'

module Evander
  
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

  class Watcher

    def initialize(source_dir, output_dir, code_dir)
      @input_dir = source_dir
      @output_dir = output_dir
      @server = WEBrick::HTTPServer.new(:Port => 8000)
      @server.mount('/', NonCachingFileHandler, output_dir)
      trap 'INT' do 
        @server.shutdown 
      end

      @source_listener = Listen.to(source_dir) do |modified, added, removed|
        _regenerate_site()
      end

      @theme_listener = Listen.to(File::expand_path('./theme')) do |modified, added, removed|
        _regenerate_site()
      end
      
    end

    def start()
      _regenerate_site()
      @source_listener.start
      @theme_listener.start
      @server.start
    end

    def _regenerate_site()
      site = Site.new(@input_dir)
      site.render(@output_dir)
    end

  end

end