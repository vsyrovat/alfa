# Migration 20121229203553
# Don't rename this file after implement migration

Sequel.migration do
  up do
    create_table :foo do
      primary_key :id, :type=>:integer, :unsigned=>true
    end
  end

  down do
    drop_table :foo
  end
end
