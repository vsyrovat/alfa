namespace :db do
  desc ""
  task :init do
    Alfa::VARS[:rakeapp_instance].instance_eval do
      config[:db].select{|name, db| db[:maintain]}.each do |db|
        # put code here
      end
    end
  end
end
