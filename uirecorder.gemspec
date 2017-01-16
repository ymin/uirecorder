# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uirecorder/version'

Gem::Specification.new do |spec|
  spec.name          = "uirecorder"
  spec.version       = UIRecorder::VERSION
  spec.authors       = ["Yi MIN"]
  spec.email         = ["minsparky@gmail.com"]

  spec.summary       = %q{UIRecorder: record ui elements and save to yml file as a template for UI test.}
  spec.description   = %q{UIRecorder: record ui elements and save to yml file as a template for UI test.}
  spec.homepage      = "http://github.com/ymin/uirecorder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
