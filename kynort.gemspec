# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kynort_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "kynort_gem"
  spec.version       = Kynort::VERSION
  spec.authors       = ["Adam Pahlevi"]
  spec.email         = ["adam.pahlevi@gmail.com"]
  spec.summary       = %q{Gem for Kynort API}
  spec.description   = %q{Kynort API gem is a gem that could communicate with the Kynort Server.}
  spec.homepage      = "http://adampahlevi.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "activemodel", "~> 4.1"
  spec.add_development_dependency "activesupport", "~> 4.1"
  spec.add_development_dependency "rest-client", "~> 1.7"
end
