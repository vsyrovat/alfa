require 'alfa/database'
require 'yaml'

# Main database for application private use
#class DB1 < Alfa::Database::MySQL
#  load_schema File.join(PROJECT_ROOT, 'db/db1')
#  load_config File.join(PROJECT_ROOT, 'config/passwords/db1.yml')
#end

module DB
  Main = Sequel.connect(YAML.load(File.open(File.expand_path('../passwords/db-main.yml', __FILE__))).symbolize_keys[:dsn], :encoding=>'utf8')
end

Dir[File.join(PROJECT_ROOT, 'db/main/models/*.rb')].each do |f|
  require f
end