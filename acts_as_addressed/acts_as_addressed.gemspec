# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_addressed/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_addressed"
  spec.version       = ActsAsAddressed::VERSION
  spec.authors       = ["Marnen Laibow-Koser"]
  spec.email         = ["marnen@marnen.org"]
  spec.description   = %q{Some quick and dirty geocoding utilities.}
  spec.summary       = %q{Some quick and dirty geocoding utilities.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  [
    ["bundler", "~> 1.3"],
    'rake',
    'byebug',
    ['rspec', '~> 2.11.0'],
    'autotest'
  ].each do |dependency|
    spec.add_development_dependency *dependency
  end
end
