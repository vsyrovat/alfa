require 'alfa/database'
require 'yaml'

# Read more about the timestamps plugin:
# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html
Sequel::Model.plugin :timestamps, update_on_create: true

# Read more about prepared statements and the plugin:
# http://sequel.jeremyevans.net/rdoc/files/doc/prepared_statements_rdoc.html
# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/PreparedStatements.html
# Sequel::Model.plugin :prepared_statements

# Read more about available plugins:
# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins.html


# Main database for application private use
module DB
  Main = Sequel.connect(YAML.load(File.open(File.expand_path('../passwords/db-main.yml', __FILE__))).symbolize_keys[:dsn], :encoding=>'utf8')
end

Dir[File.join(PROJECT_ROOT, 'db/main/models/*.rb')].each do |f|
  require f
end

Sequel.extension :blank
