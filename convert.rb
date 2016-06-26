Dir.chdir("./source/blog/") do
  Dir.foreach(".") do |child|
    if(child == "." || child == "..")
      next
    end 
    if(File.directory?(child))
      Dir.chdir(child) do 
        config_lines = []
        post_lines = []
        if(File.exist?("index.markdown"))
          in_config = false
          File.open("index.markdown", "r").each_line do |line|
            if(line.start_with?("---"))
              in_config = !in_config
              next
            end
            if(in_config)
              config_lines << line
            else
              post_lines << line
            end
          end
        end
        File.open("config.yaml", "w") do |f|
          f.puts("---")
          f.puts(config_lines)
        end
        File.open("index.markdown", "w") do |f|
          f.puts(post_lines)
        end
      end
    end
  end
end