namespace :db do
  desc ""
  task :init do
    Alfa::VARS[:rakeapp_instance].instance_eval do
      config[:db].select{|name, db| db[:maintain]}.each do |name, db|
        # put code here
      end
    end
  end

  desc "Create dumb migration for certain database and puts them into PROJECT_ROOT/db/%database%/migration"
  task :'add-migration' do
    Alfa::VARS[:rakeapp_instance].instance_eval do
      unless ENV['db']
        puts "Please specify database such as: rake db:add-migration db=database"
        puts "Known maintainable databases: " << config[:db].select{|name, db| db[:maintain]}.map{|name, db| name}.join(', ')
        exit
      end
      db_name = ENV['db'].to_sym
      unless config[:db][db_name]
        puts "Unknown database. Known maintainable databases: " << config[:db].select{|name, db| db[:maintain]}.map{|name, db| name}.join(', ')
        exit
      end
      db = config[:db][db_name]
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
