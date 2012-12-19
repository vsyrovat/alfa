namespace :db do
  task :require_db do
    env_db = nil
    Alfa::VARS[:rakeapp_instance].instance_eval do
      unless ENV['db']
        puts "Please specify database such as: db=database"
        puts "Known maintainable databases: " << config[:db].select{|name, db| db[:maintain]}.map{|name, db| name}.join(', ')
        exit
      end
      db_name = ENV['db'].to_sym
      unless config[:db][db_name]
        puts "Unknown database. Known maintainable databases: " << config[:db].select{|name, db| db[:maintain]}.map{|name, db| name}.join(', ')
        exit
      end
      env_db = config[:db][db_name]
    end
    @env_db = env_db
  end

  task :optional_db do
    env_db = nil
    Alfa::VARS[:rakeapp_instance].instance_eval do
      if ENV['db']
        db_name = ENV['db'].to_sym
        unless config[:db][db_name]
          puts "Unknown database. Known maintainable databases: " << config[:db].select{|name, db| db[:maintain]}.map{|name, db| name}.join(', ')
          exit
        end
        env_db = config[:db][db_name]
      end
    end
    @env_db = env_db
  end

  desc "Reset schema (drop all tables)"
  task :reset => :require_db do
    @env_db[:instance].drop_table(*@env_db[:instance].tables)
  end

  desc "Create dumb migration for certain database and puts them into PROJECT_ROOT/db/%database%/migration"
  task :'add-migration' => :require_db do
    db = @env_db
    Alfa::VARS[:rakeapp_instance].instance_eval do
      unless db[:path]
        puts "Error: not specified path for database #{db_name}"
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
      migration_file = File.join(db[:path], 'migrations', filename)
      if File.exist?(migration_file)
        puts "Error: file #{migration_file} already exists, exiting"
        exit
      end

      File.open(migration_file, 'w') do |f|
        f.write pattern
        puts "Created migration #{migration_file}"
      end

    end
  end

end
