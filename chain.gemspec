# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chain/version'

Gem::Specification.new do |spec|
  spec.name          = "chain"
  spec.version       = Chain::VERSION
  spec.authors       = ["Stefan Novak"]
  spec.email         = ["stefan.louis.novak@gmail.com"]
  spec.description   = %q{Access API endpoints via method chaining in Ruby.}
  spec.summary       = %q{Access API endpoints via method chaining in Ruby.}
  spec.homepage      = "https://github.com/slnovak/chain"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "webmock", "~> 1.15.2"

  spec.add_dependency "faraday", "~> 0.8.8"
  spec.add_dependency "hashie", "~> 2.0.5"
end
