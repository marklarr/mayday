# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mayday/version'

Gem::Specification.new do |spec|
  spec.name          = "mayday"
  spec.version       = Mayday::VERSION
  spec.authors       = ["Mark Larsen"]
  spec.email         = ["larse503@gmail.com"]
  spec.summary       = %q{Custom warnings and errors}
  spec.description   = %q{Custom warnings and errors}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "pry", "~> 0.9"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"

  spec.add_dependency 'clamp', '~> 0.6.3'
  spec.add_dependency 'sourcify', '~> 0.6.0rc4'
  spec.add_dependency 'xcodeproj', '~> 0.19.3'
end
