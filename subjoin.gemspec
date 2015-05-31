# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'subjoin/version'

Gem::Specification.new do |spec|
  spec.name          = "subjoin"
  spec.version       = Subjoin::VERSION
  spec.authors       = ["Sean Redmond"]
  spec.email         = ["sean.redmond@gmail.com"]
  spec.summary       = %q{A practical wrapper for JSON-API interactions.}
  spec.description   = %q{A practical wrapper for JSON-API interactions.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
end
