# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_inventory_unit_fix/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_inventory_unit_fix'
  s.version     = SolidusInventoryUnitFix::VERSION
  s.summary     = 'Adds quantity to inventory units and stops generating so many of them'
  s.description = 'This gem adds a quantity field to inventory_units, rather than
  generating a new inventory unit for each individual quantity of a line_item.
  This is a huge performance boost for any order that has more than a handful of
  individual items.'
  s.license     = 'BSD-3-Clause'
  s.author      = 'Sean Denny'
  s.email       = 'seand7565@gmail.com'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core', '~> 2.4'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '0.37.2'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
