require File.expand_path('../../../../version', __FILE__)
require 'fileutils'
require 'alfa/support'

PROJECT_NAME = $*[1]

sr = {
  '#{ALFA_VERSION}' => ALFA_VERSION,
  '#{PROJECT_NAME}' => PROJECT_NAME,
}

target_dir = File.join(Dir.pwd, PROJECT_NAME)
raise "file or directory #{PROJECT_NAME} already exists" if File.exists?(target_dir)
Dir.mkdir PROJECT_NAME

puts "Created new project in #{PROJECT_NAME}"

begin
  print "Copy dummy project... "
  source_base_len = File.expand_path('../../../../dummy/project', __FILE__).length + 1
  Dir[File.expand_path('../../../../dummy/project/**/{*,.[^.]*}', __FILE__)].each do |path|
    relpath = path[source_base_len..-1]
    target = File.join(target_dir, relpath)
    if File.directory?(path)
      FileUtils.mkdir_p target, :mode => 0755
    else
      if File.extname(relpath) == '.source'
        File.open(target.chomp('.source'), File::WRONLY | File::CREAT) do |f|
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

puts "Run 'cd #{PROJECT_NAME} && bundle install' manually"

# begin
#   print "Bundle install... "
#   FileUtils.cd PROJECT_NAME
#   `bundle install`
#   print "done"
# ensure
#   FileUtils.cd '..'
#   puts ""
# end
