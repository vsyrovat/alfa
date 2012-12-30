require File.expand_path('../../../../version', __FILE__)
require 'fileutils'
require 'alfa/support'

sr = %w(
  ALFA_VERSION
).map{|const| ['#{%s}' % const, Kernel.const_get(const)]}

project_name = $*[1]
target_dir = File.join(Dir.pwd, project_name)
raise "file or directory #{project_name} already exists" if File.exists?(target_dir)
Dir.mkdir project_name

puts "Created new project in #{project_name}"

begin
  print "Copy dummy project... "
  source_base_len = File.expand_path('../../../../dummy/project', __FILE__).length + 1
  Dir[File.expand_path('../../../../dummy/project/**/{*,.[^.]*}', __FILE__)].each do |path|
    relpath = path[source_base_len..-1]
    target = File.join(target_dir, relpath)
    if File.directory?(path)
      FileUtils.mkdir_p target, :mode => 0755
    else
      case relpath
        when 'Gemfile'
          File.open(target, File::WRONLY | File::CREAT) do |f|
            f.write(File.read(path).strtr(sr))
          end
        else
          FileUtils.cp(path, target)
      end
    end
  end
  print "done"
ensure
  puts ""
end

begin
  print "Bundle install... "
  FileUtils.cd project_name
  `bundle install`
  print "done"
ensure
  FileUtils.cd '..'
  puts ""
end
