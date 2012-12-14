project_name = $*[1]
target_dir = File.join(Dir.pwd, project_name)
raise "file or directory #{project_name} already exists" if File.exists?(target_dir)
Dir.mkdir project_name
