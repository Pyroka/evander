module Evander

  class Page

    def initialize(path)
      @sub_pages = Page.get_sub_pages(File.dirname(path))
    end

    def self.get_sub_pages(dirname)
      pages = Hash.new
      Dir.foreach(dirname) do |child|
        Dir.chdir(dirname) do
          if(child == "." || child == ".." || !File.directory?(child))
            next
          end

          index_path = File.join(child, "index.markdown")
          if(File.exist?(index_path))
            pages[child] = Page.new(index_path)
          else
            pages[child] = Page.get_sub_pages(child)
          end
        end
      end
      pages
    end

  end

end