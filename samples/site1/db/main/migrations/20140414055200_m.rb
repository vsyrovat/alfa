# Migration 20140414055200
# Don't rename this file after implement migration

Sequel.migration do
  up do
    # Put forward migration code here
    # Use Sequel migration syntax (http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html) or native SQL (run "SQL command")
    alter_table :users do
      add_column :groups, 'text'
    end
  end

  down do
    # Put backward migration code here
    alter_table :users do
      drop_column :groups
    end
  end
end
