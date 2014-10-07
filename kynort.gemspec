# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kynort_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "kynort"
  spec.version       = Kynort::VERSION
  spec.authors       = ["Adam Pahlevi"]
  spec.email         = ["adam.pahlevi@gmail.com"]
  spec.summary       = %q{Gem for Kynort, searching and booking flights and hotels}
  spec.description   = %q{Kynort is a ruby gem to communicate with Kynort (kynort.aquiforth.com)}
  spec.homepage      = "http://kynorth.aquiforth.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.1"
  # spec.add_development_dependency "activemodel", ">= 3.0"
  spec.add_development_dependency "activesupport", ">= 3.0"
  spec.add_development_dependency "rest-client", "1.6.7"
  spec.add_development_dependency "rails", ">= 3.0"
  spec.add_development_dependency "mime-types", "1.25.1"
end
