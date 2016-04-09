# encoding: utf-8

lib_dir = File.join(File.dirname(__FILE__),'lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'bundler/stats/version'

Gem::Specification.new do |gem|

  gem.name    = "bundler-stats"
  gem.version = Bundler::Stats::VERSION

  gem.summary     = "Dependency investigation for Bundler"
  gem.description = "Looks through your lockfile and tries to identify problematic use of dependencies"
  gem.licenses    = "MIT"
  gem.authors     = "Joseph Mastey"
  gem.email       = "jmmastey@gmail.com"
  gem.homepage    = "http://github.com/jmmastey/bundler-stats"

  glob = lambda { |patterns| gem.files & Dir[*patterns] }

  gem.files       = `git ls-files`.split($/)
  gem.executables = glob['bin/*'].map { |path| File.basename(path) }
  gem.default_executable = gem.executables.first if Gem::VERSION < '1.7.'

  gem.extensions       = glob['ext/**/extconf.rb']
  gem.test_files       = glob['{spec/{**/}*_spec.rb']
  gem.extra_rdoc_files = glob['*.{txt,md}']

  gem.require_paths = %w[ext lib].select { |dir| File.directory?(dir) }

  gem.add_dependency "bundler", "~> 1.9"
  gem.add_dependency "thor", "~> 0.19"

  gem.add_development_dependency "rspec", "~> 3.4"
  gem.add_development_dependency "guard", "~> 2.13"
  gem.add_development_dependency "pry", "~> 0.10"
end
