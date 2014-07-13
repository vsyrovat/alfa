# Migration 20000000000000
# Don't rename this file after implement migration

Sequel.migration do
  up do
    # Put forward migration code here
    # Use Sequel migration syntax (http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html) or native SQL (run "SQL command")
    create_table :users do
      primary_key :id
      column :login, String, null: false
      column :passhash, String, text: true, null: false
      column :groups, String, text: true
      column :email, String
      column :first_name, String, size: 100
      column :last_name, String, size: 100
      column :created_at, DateTime
      column :updated_at, DateTime
      unique :login
      unique :email
    end
    User.set_dataset :users
  end

  down do
    # Put backward migration code here
    drop_table :users
  end
end
