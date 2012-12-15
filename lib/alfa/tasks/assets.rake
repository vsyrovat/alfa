require 'fileutils'

namespace :assets do

  desc 'Copy assets from gem folder to PROJECT_ROOT/public/~assets'
  task :copy do
    src = File.expand_path('../../../../assets', __FILE__)
    dest = File.join(DOCUMENT_ROOT, '~assets')
    FileUtils.mkdir(dest, mode: 0755) unless File.directory?(dest)
    Dir[File.join(src, '*')].each do |f|
      FileUtils.cp_r(f, dest)
    end
    puts "Assets copied from #{src} to #{dest}"
  end

end
