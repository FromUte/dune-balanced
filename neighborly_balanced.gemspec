$:.push File.expand_path('../lib', __FILE__)

require 'neighborly_balanced/version'

Gem::Specification.new do |s|
  s.name        = 'neighborly_balanced'
  s.version     = NeighborlyBalanced::VERSION
  s.authors     = ['Irio Musskopf', 'Josemar Luedke']
  s.email       = %w(iirineu@gmail.com josemarluedke@gmail.com)
  s.homepage    = 'TODO'
  s.summary     = 'Catarse\'s integration with Balanced Payments.'
  s.description = 'Catarse\'s integration with Balanced Payments.'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.0.2'

  s.add_development_dependency 'sqlite3'
end
