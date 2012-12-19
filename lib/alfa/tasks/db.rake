require 'sequel/extensions/migration'
require 'alfa/logger'

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

  # Auxiliary task
  # Set logger($stdout) for all databases
  task :stdout_logger do
    @stdout_logger ||= Alfa::Logger.new($stdout)
    dbs.each_value do |db|
      db[:instance].loggers << @stdout_logger
    end
  end

  desc "Reset schema (drop all tables)"
  task :reset => [:require_db, :stdout_logger] do
    @db[:instance].drop_table(*@db[:instance].tables)
  end

  desc "Create dumb migration for certain database and puts them into PROJECT_ROOT/db/%database%/migration"
  task :'add-migration' => [:require_db, :stdout_logger] do
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
  task :migrate => [:optional_db, :stdout_logger] do
    if @db
      Sequel::Migrator.run(@db[:instance], File.join(@db[:path], 'migrations'))
    else
      dbs.each do |name, db|
        Sequel::Migrator.run(db[:instance], File.join(db[:path], 'migrations'))
      end
    end
  end

  namespace :migrate do
    desc "Migrate database 1 step up"
    task :up => [:require_db, :stdout_logger] do
      migrator = Sequel::TimestampMigrator.new(@db[:instance], File.join(@db[:path], 'migrations'))
      if migrator.migration_tuples
        m = migrator.migration_tuples.first
        if m[2] == :up
          target = m[1].split('_').first.to_i
          Sequel::Migrator.run(@db[:instance], File.join(@db[:path], 'migrations'), :target=>target)
        end
      end
    end

    desc "Migrate database 1 step down"
    task :down => [:require_db, :stdout_logger] do
      migrator = Sequel::TimestampMigrator.new(@db[:instance], File.join(@db[:path], 'migrations'))
      to_rollback = migrator.applied_migrations.last
      if to_rollback
        target = migrator.applied_migrations[0..-2].last # last but one applied migration
        if target
          target = target.split('_').first.to_i
        else
          target = 0
        end
        Sequel::Migrator.run(@db[:instance], File.join(@db[:path], 'migrations'), :target=>target)
      else
        puts "Nothing to rollback"
      end
    end
  end

end
