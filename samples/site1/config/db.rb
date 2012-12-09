require 'alfa/database'

# main database for application private use
#class DB1 < Alfa::Database::MySQL
#  load_schema File.join(PROJECT_ROOT, 'db/db1')
#  load_config File.join(PROJECT_ROOT, 'config/passwords/db1.yml')
#end

require File.expand_path('../../schemas/main/init', __FILE__)