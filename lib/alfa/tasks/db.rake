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

  desc "Drop all tables in schema"
  task :drop => [:require_db, :stdout_logger] do
    @db[:instance].tables.each do |table|
      @db[:instance].foreign_key_list(table).each do |key|
        @db[:instance].alter_table table do
          drop_foreign_key(key[:columns])
        end
      end
    end
    @db[:instance].drop_table(*@db[:instance].tables)
  end

  desc "Create dumb migration for certain database and puts them into PROJECT_ROOT/db/%database%/migration"
  task :'new-migration' => [:require_db, :stdout_logger] do
    unless @db[:path]
      puts "Error: not specified path for database #{@db_name}"
      exit
    end
    ts = Time.now.utc.strftime('%Y%m%d%H%M%S')
    pattern = <<EOL
# Migration #{ts}
# Don't rename this file after implement migration

Sequel.migration do
  up do
    # Put forward migration code here
    # Use Sequel migration syntax (http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html) or native SQL (run "SQL command")
  end

  down do
    # Put backward migration code here
  end
end

# Awailable commands:
#
# create_table :table_name do
#   primary_key :id
#   column :column_name, ColumnType, ...
#   index [:column1, :column2], name: :index_name
#   unique [:column1, :column2], name: :index_name
#   foreign_key :column_name, :unique=>true, :type=>'varchar(16)', :on_delete=>..., :on_update=>...
#   foreign_key [:column1, :column2], :column_name, :name=>'key_name'
#   full_text_index ...
#   spatial_index ...
#   constraint ...
#   check ...
# end
#
# create_table :table_name do
#   column :column1, Integer
#   column :column2, Integer
#   primary_key [:column1, :column2]
# end
#
# create_join_table ...
#
# create_table :as=> ...
#
# create_table! ...
#
# create_table? ...
#
# drop_table :table_name
#
# drop_table? :table_name
#
# alter_table :table_name do
#   add_column ...
#   drop_column ...
#   rename_column ...
#   add_primary_key ...
#   add_foreign_key ...
#   drop_foreign_key ...
#   add_index ...
#   drop_index ...
#   add_full_text_index ...
#   add_spatial_index ...
#   add_constraint ...
#   add_unique_constraint ...
#   drop_constraint ...
#   set_column_default ...
#   set_column_type ...
#   set_column_allow_null ...
#   set_column_not_null ...
# end
#
# rename_table ...
#
# create_view ...
#
# create_or_replace_view ...
#
# drop_view ...
EOL
    filename = "#{ts}_m.rb"
    migration_file = File.join(@db[:path], 'migrations', filename)
    if File.exist?(migration_file)
      puts "Error: file #{migration_file} already exists, exiting"
      exit
    end

    File.open(migration_file, 'w') do |f|
      f.write pattern
      puts "Create migration #{migration_file}"
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

  desc "Test databases connection parameters"
  task :test do
    errors = 0
    dbs.each do |name, db|
      begin
        db[:instance].test_connection
      rescue Sequel::DatabaseConnectionError => e
        errors = errors + 1
        puts e.message
      end
    end
    if errors > 0
      puts "Some DSN problems found. Check config/passwords/db-*.yml"
    else
      puts "All DSNs are ok!"
    end
  end

  desc 'Seed chosen Database'
  task :seed => [:optional_db, :stdout_logger] do
    if @db
      Kernel.load File.join(@db[:path], 'seed.rb')
    else
      dbs.each do |name, db|
        Kernel.load File.join(db[:path], 'seed.rb')
      end
    end
  end
end
