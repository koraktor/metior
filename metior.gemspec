require 'bundler'

require File.expand_path(File.dirname(__FILE__) + '/lib/metior/version')

Gem::Specification.new do |s|
  s.name        = "metior"
  s.version     = Metior::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Sebastian Staudt' ]
  s.email       = [ 'koraktor@gmail.com' ]
  s.homepage    = 'http://koraktor.de/metior'
  s.summary     = 'A source code history analyzer API'
  s.description = 'Metior is a source code history analyzer that provides various statistics about a source code repository and its change over time.'

  s.add_dependency 'bundler', '~> 1.0.14'
  Bundler.definition.dependencies.each do |dep|
    if dep.groups.include?(:development) || dep.groups.include?(:test)
      s.add_development_dependency(dep.name, dep.requirement.to_s)
    else
      s.add_dependency(dep.name, dep.requirement.to_s)
    end
  end

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- test/*`.split("\n")
  s.require_paths      = [ 'lib' ]
end
