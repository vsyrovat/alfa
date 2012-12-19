require 'sequel/extensions/migration'

# All maintainable databases
def dbs
  Alfa::VARS[:rakeapp_instance].instance_eval do
    config[:db].select{|name, db| db[:maintain]}
  end
end

namespace :db do
  # Auxiliary task
  # Check is database name given, if not given - exit with error message
  task :require_db do
    unless ENV['db']
      puts "Please specify database such as: db=database"
      puts "Known maintainable databases: " << dbs.map{|name, db| name}.join(', ')
      exit
    end
    @db_name = ENV['db'].to_sym
    @db = dbs[@db_name]
    unless @db
      puts "Unknown database \"#{ENV['db']}\". Known maintainable databases: " << dbs.map{|name, db| name}.join(', ')
      exit
    end
  end

  # Auxiliary task
  # Set @db if database name given
  task :optional_db do
    @db = nil
    @db_name = nil
    if ENV['db']
      @db_name = ENV['db'].to_sym
      @db = dbs[@db_name]
      unless @db
        puts "Unknown database. Known maintainable databases: " << dbs.map{|name, db| name}.join(', ')
        exit
      end
    end
  end

  desc "Reset schema (drop all tables)"
  task :reset => :require_db do
    @db[:instance].drop_table(*@db[:instance].tables)
  end

  desc "Create dumb migration for certain database and puts them into PROJECT_ROOT/db/%database%/migration"
  task :'add-migration' => :require_db do
    unless @db[:path]
      puts "Error: not specified path for database #{@db_name}"
      exit
    end
    ts = Time.now.utc.strftime('%Y%m%d%H%M%S')
    pattern = <<EOL
# Migration #{ts}
# You can rename this file before implement migration

Sequel.migration do
  up do
    # put up migration code here
  end

  down do
    # put down migration code here
  end
end
EOL
    filename = "#{ts}_m.rb"
    migration_file = File.join(@db[:path], 'migrations', filename)
    if File.exist?(migration_file)
      puts "Error: file #{migration_file} already exists, exiting"
      exit
    end

    File.open(migration_file, 'w') do |f|
      f.write pattern
      puts "Created migration #{migration_file}"
    end
  end

  desc "Migrate database(s)"
  task :migrate => :optional_db do
    if @db
      Sequel::Migrator.run(@db[:instance], File.join(@db[:path], 'migrations'))
    else
      dbs.each do |name, db|
        Sequel::Migrator.run(db[:instance], File.join(db[:path], 'migrations'))
      end
    end
  end
end
