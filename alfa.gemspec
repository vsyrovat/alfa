Gem::Specification.new do |spec|
  spec.name        = 'alfa'
  spec.version     = '0.0.1.pre'
  spec.date        = '2012-09-21'
  spec.summary     = "Alfa CMF"
  spec.description = ""
  spec.authors     = ["Valentin Syrovatskiy"]
  spec.email       = 'vsyrovat@gmail.com'
  spec.files       = Dir['lib/**/*.rb'] + Dir['test/**/*.rb'] + Dir['assets/**']
  spec.homepage    = 'http://alfa.7side.ru'
  spec.add_runtime_dependency 'rvm',    '~> 1.11.3'
  spec.add_runtime_dependency 'rake',   '~> 0.9.2'
  spec.add_runtime_dependency 'rack',   '~> 1.4.1'
  spec.add_runtime_dependency 'ruty',   '~> 0.0.1'
  spec.add_runtime_dependency 'mysql2', '~> 0.3.11'
  spec.add_runtime_dependency 'sequel', '~> 3.40.0'
end