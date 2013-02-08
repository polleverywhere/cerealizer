# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cerealizer/version'

Gem::Specification.new do |gem|
  gem.name          = "cerealizer"
  gem.version       = Cerealizer::VERSION
  gem.authors       = ["Brad Gessler"]
  gem.email         = ["brad@polleverywhere.com"]
  gem.description   = %q{Serialize and deserialize classes and JSON.}
  gem.summary       = %q{Dive into the nitty gritty details of serializing and deserializing between objects and a hash.}
  gem.homepage      = "http://github.com/polleverywhere/cerealizer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '>= 2.9.0'
end
