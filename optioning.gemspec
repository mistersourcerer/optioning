# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'optioning/version'

Gem::Specification.new do |spec|
  spec.name          = "optioning"
  spec.version       = Optioning::VERSION
  spec.authors       = ["Ricardo Valeriano"]
  spec.email         = ["ricardo.valeriano@gmail.com"]
  spec.summary       = %q{An object oriented way to treat our beloved last parameter: Hash.}
  spec.description   = %q{An easy way to retrieve, store, filter and deprecate `options` passed to a method. Where `options` are the keys on our beloved `Hash` as last parameter for a method call.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
end
