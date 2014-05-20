require './version'
require 'bcrypt'

Gem::Specification.new do |spec|
  spec.name        = 'alfa'
  spec.version     = ALFA_VERSION
  spec.date        = Time.now.utc.strftime('%Y-%m-%d')
  spec.summary     = "Alfa CMF"
  spec.description = ""
  spec.author      = "Valentin Syrovatskiy"
  spec.email       = 'vsyrovat@gmail.com'
  spec.files       = Dir['lib/**/*'] + Dir['test/**/*'] + Dir['assets/**/*'] + Dir['bin/**/*'] + Dir.glob('dummy/**/*', File::FNM_DOTMATCH) + Dir['version.rb']
  spec.executables << 'alfa'
  spec.add_runtime_dependency 'rvm',    '~> 1.11', '>= 1.11.3'
  spec.add_runtime_dependency 'rake',   '~> 10.3', '>= 10.3.1'
  spec.add_runtime_dependency 'rack',   '~> 1.5', '>= 1.5.2'
  spec.add_runtime_dependency 'ruty',   '0.0.1'
  spec.add_runtime_dependency 'mysql2', '~> 0.3', '>= 0.3.15'
  spec.add_runtime_dependency 'sequel', '~> 4.9', '>= 4.9.0'
  spec.add_runtime_dependency 'rack-session-sequel', '~> 0.0', '>= 0.0.1'
  spec.add_runtime_dependency 'haml',   '4.0.5'
  spec.add_runtime_dependency 'template-inheritance', '0.3.1'
  spec.add_runtime_dependency 'bcrypt', '~> 3.1', '>= 3.1.7'
end
