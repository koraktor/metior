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

  s.add_dependency 'grit', '~> 2.5.0'
  s.add_dependency 'mustache', '~> 0.99.4'
  s.add_dependency 'octokit', '~> 1.4.0'
  s.add_dependency 'rugged', '~> 0.16.0'

  if RUBY_VERSION.match(/^1\.8/)
    s.add_dependency 'hashery', '~> 1.5.0'
    s.add_dependency 'json', '~> 1.7.3'
  end

  s.add_development_dependency 'mocha', '~> 0.11.3'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'shoulda', '~> 2.11.3'
  s.add_development_dependency 'yard', '~> 0.8.0'

  s.executables   = [ 'metior' ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = [ 'lib' ]
end
