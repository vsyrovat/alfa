require 'alfa/database'
require 'yaml'

# Main database for application private use
module DB
  Main = Sequel.connect(YAML.load(File.open(File.expand_path('../passwords/db-main.yml', __FILE__))).symbolize_keys[:dsn], :encoding=>'utf8')
end

Dir[File.join(PROJECT_ROOT, 'db/main/models/*.rb')].each do |f|
  require f
end
