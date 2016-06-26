require 'FileUtils'

Dir.foreach("./source/blog") do |child|
  Dir.chdir("./source/blog") do
    if(child.start_with?("2"))
      dirname = File.basename(child, ".markdown")
      Dir.mkdir(dirname)
      FileUtils.mv(child, dirname + "/index.markdown")
    end
  end
end