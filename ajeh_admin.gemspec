$:.push File.expand_path('../lib', __FILE__)

require 'ajeh_admin/version'

Gem::Specification.new do |s|
  s.name        = 'ajeh_admin'
  s.version     = AjehAdmin::VERSION
  s.authors     = ['Alistair Holt']
  s.email       = ['hello@alistairholt.co.uk']
  s.homepage    = ''
  s.summary     = 'Summary of AjehAdmin.'
  s.description = 'Description of AjehAdmin.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2.5.1'
  s.add_development_dependency 'sqlite3'
end
