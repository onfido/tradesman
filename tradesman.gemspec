$:.push File.expand_path('../lib', __FILE__)
require 'tradesman/version'

Gem::Specification.new do |s|
  s.name = 'tradesman'
  s.version = Tradesman::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Blake Turner', 'Morgan Bruce']
  s.description = 'Encapsulate common application behaviour with dynamically generated classes'
  s.summary = 'Tradesman dynamically generates classes with human-readble names that handle the pass, fail, and invalid results of common create, update, and delete actions.'
  s.email = 'mail@blakewilliamturner.com'
  s.homepage = 'https://github.com/onfido/tradesman'
  s.license = 'MIT'

  s.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  s.test_files    = Dir.glob("{spec}/**/*")
  s.require_paths = ['lib']


  s.add_runtime_dependency 'tzu', '~> 0.1'
  s.add_runtime_dependency 'horza', '~> 1.0', '>= 1.0.3'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'activerecord', '>= 4.2'
  s.add_development_dependency 'activesupport', '>= 4.2'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'bundler-audit'
end
