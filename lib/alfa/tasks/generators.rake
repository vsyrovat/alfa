namespace :+ do

  task :require_model => [:'db:require_db'] do
    unless ENV['model']
      puts "Please specify model in single form such as: model=images"
      exit
    end
    @model_name = ENV['model'].to_sym
    if File.exist?(File.join(PROJECT_ROOT, 'db', @db_name.to_s, 'models', "#{@model_name.to_s}.rb"))
      puts "Model #{@model_name} for db #{@db_name} already exists"
      exit
    end
  end

  desc 'Create model'
  task :model => [:'db:require_db', :require_model] do
    model_filename = Alfa::Support.underscore_name(@model_name)
    model_classname = Alfa::Support.camelcase_name(@model_name)
    db_classname = Alfa::Support.camelcase_name(@db_name)
    ts = Time.now.utc.strftime('%Y%m%d%H%M%S')
    pattern = <<EOL
# Migration #{ts} for model #{model_classname}
# Don't rename this file after implement migration

Sequel.migration do
  up do
    # Use Sequel migration syntax (http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html) or native SQL (run "SQL command")
    create_table :#{model_filename}s do
      primary_key :id, type: :integer, unsigned: true
      # ...
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :#{model_filename}s
  end
end
EOL
    filename = "#{ts}_#{model_filename}.rb"
    migration_file = File.join(@db[:path], 'migrations', filename)
    if File.exist?(migration_file)
      puts "Error: file #{migration_file} already exists, exiting"
      exit
    end
    File.open(migration_file, 'w') do |f|
      f.write pattern
      puts "Create migration #{migration_file}"
    end

    pattern = <<EOL
class #{model_classname} < Sequel::Model(DB::#{db_classname}[:#{model_filename}s])
  # Uncomment following plugins if necessary:
  # plugin :timestamps, update_on_create: true
  # plugin :prepared_statements
  # plugin :serialization, %method%, %field%
  # Read more about available plugins: http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins.html
end
EOL
    filename = "#{model_filename}.rb"
    model_file = File.join(@db[:path], 'models', filename)
    if File.exist?(model_file)
      puts "Error: file #{model_file} already exists, exiting"
      exit
    end
    File.open(model_file, 'w') do |f|
      f.write pattern
      puts "Create migration #{model_file}"
    end
  end
end