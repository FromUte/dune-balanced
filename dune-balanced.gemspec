# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dune/balanced/version'

Gem::Specification.new do |spec|
  spec.name          = 'dune-balanced'
  spec.version       = Dune::Balanced::VERSION
  spec.authors       = ['Pierro']
  spec.email         = %w(legrand.work@gmail.com)
  spec.summary       = 'dune integration with Balanced Payments From Neighborly'
  spec.description   = 'This is the base to integrate Balanced Payments on dune-investissement'
  spec.homepage      = 'https://github.com/FromUte/dune-balanced'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # faraday_middleware 0.9.1 is raising
  # NoMethodError: undefined method `register_middleware' for #<Faraday::Connection:0x00000002ebc178>
  spec.add_dependency 'faraday',            '0.8.9'
  spec.add_dependency 'faraday_middleware', '0.9.0'

  spec.add_dependency 'balanced',           '~> 1.1'
  spec.add_dependency 'draper',             '~> 1.3'
  spec.add_dependency 'rails',              '~> 4.0'
  spec.add_development_dependency 'rspec-rails',      '~> 2.14'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'sqlite3',          '~> 1.3'
end
