require 'alfa/database'

# main database for application private use
#class DB1 < Alfa::Database::MySQL
#  load_schema File.join(PROJECT_ROOT, 'db/db1')
#  load_config File.join(PROJECT_ROOT, 'config/passwords/db1.yml')
#end

module Databases
  MAIN = Sequel.connect('mysql2://root:@localhost/site')
end

Dir[File.join(PROJECT_ROOT, 'db/db1/models/*.rb')].each do |f|
  require f
end