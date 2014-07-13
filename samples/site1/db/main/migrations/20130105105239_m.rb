# Migration 20130105105239
# Don't rename this file after implement migration

Sequel.migration do
  up do
    # Put forward migration code here
    # Use Sequel migration syntax (http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html) or native SQL (run "SQL command")
    create_table :users do
      primary_key :id, :type=>:integer, :unsigned=>true
      column :login, String, null: false
      column :passhash, String, text: true, null: false
      index :login, :name=>:i_login, :unique=>true
    end
  end

  down do
    # Put backward migration code here
    drop_table :users
  end
end
