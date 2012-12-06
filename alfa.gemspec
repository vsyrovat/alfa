Gem::Specification.new do |spec|
  spec.name        = 'alfa'
  spec.version     = '0.0.1.pre'
  spec.date        = '2012-09-21'
  spec.summary     = "Alfa CMF"
  spec.description = ""
  spec.author      = "Valentin Syrovatskiy"
  spec.email       = 'vsyrovat@gmail.com'
  spec.files       = Dir['lib/**/*.rb'] + Dir['test/**/*.rb'] + Dir['assets/**']
  spec.homepage    = 'http://alfa.7side.ru'
  spec.add_runtime_dependency 'rvm',    '~> 1.11' # 1.11.3.5
  spec.add_runtime_dependency 'rake',   '~> 10.0' # 10.0.2
  spec.add_runtime_dependency 'rack',   '~> 1.4' # 1.4.1
  spec.add_runtime_dependency 'ruty',   '= 0.0.1' # 0.0.1
  spec.add_runtime_dependency 'mysql2', '~> 0.3' # 0.3.11
  spec.add_runtime_dependency 'sequel', '~> 3.42' # 3.42.0
end