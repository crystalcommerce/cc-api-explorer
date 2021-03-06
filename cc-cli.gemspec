# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cc/api/explorer/version'

Gem::Specification.new do |spec|
  spec.name          = "cc-cli"
  spec.version       = Cc::Api::Explorer::VERSION
  spec.authors       = ["Neil Marion dela Cruz", "Michael Xavier"]
  spec.email         = ["developers@crystalcommerce.com"]
  spec.summary       = %q{CrystalCommerce API Explorer}
  spec.description   = %q{This is a command line client for exploring CrystalCommerce APIs}
  spec.homepage      = "https://github.com/crystalcommerce/cc-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_runtime_dependency "command_line_reporter"
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
