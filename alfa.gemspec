Gem::Specification.new do |spec|
  spec.name        = 'alfa'
  spec.version     = '0.0.1.pre'
  spec.date        = '2012-09-21'
  spec.summary     = "Alfa CMF"
  spec.description = ""
  spec.authors     = ["Valentin Syrovatskiy"]
  spec.email       = 'vsyrovat@gmail.com'
  spec.files       = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  spec.homepage    = 'http://alfa.7side.ru'
  spec.add_runtime_dependency 'rvm'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'ruty'
  spec.add_runtime_dependency 'mysql2'

  spec.add_development_dependency 'rvm'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'ruty'
  spec.add_development_dependency 'mysql2'

end