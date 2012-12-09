module DB
  Main = Sequel.connect('mysql2://root:@localhost/site')
end

Dir[File.join(PROJECT_ROOT, 'schemas/main/models/*.rb')].each do |f|
  require f
end