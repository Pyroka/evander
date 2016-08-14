require 'webrick'
require 'listen'
require 'FileUtils'

require_relative './evander/generation/command_line_options'
require_relative './evander/generation/watcher'
require_relative './evander/generation/generator'

module Evander

  options = CommandLineOptions.parse(ARGV)

  case options.mode
  when :generate
    puts "Generating site"
    Generator.new(options.input_dir, options.output_dir).generate()
  when :watch
    puts "Watching for changes"
    watcher = Watcher.new(options.input_dir, options.output_dir)
    watcher.start
  when :new_post
    if(options.params.length < 1)
      puts "Need to provide a title for the post"
    else
      new_post_dir = File.join(options.input_dir, 'blog', Time.now.strftime('%Y-%m-%d') + '-' + options.params[0].gsub(/[^\w\d]/, '-').gsub(/-+/, '-').downcase)
      FileUtils.mkdir_p(new_post_dir)
      FileUtils.touch(File.join(new_post_dir, 'index.markdown'))
      File.open(File.join(new_post_dir, 'config.yaml'), 'w') do |file|
        file.puts('---')
        file.puts('rss: true')
        file.puts('template: blog')
        file.puts('title: "' + options.params[0].gsub(/&/, '&amp;') + '"')
        file.puts('date: ' + Time.now.strftime('%Y-%m-%d %H:%M:%S %z'))
        file.puts('categories: []')
      end
    end
  end

end