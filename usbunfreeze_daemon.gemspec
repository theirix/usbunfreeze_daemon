# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'usbunfreeze_daemon/version'

Gem::Specification.new do |spec|
  spec.name          = "usbunfreeze_daemon"
  spec.version       = UsbunfreezeDaemon::VERSION
  spec.authors       = ["theirix"]
  spec.email         = ["theirix@gmail.com"]
  spec.summary       = %q{Usbunfreeze Daemon}
  spec.description   = %q{Daemon application for Usbunfreeze kit}
  spec.homepage      = "http://github.com/theirix/usbunfreeze_daemon"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "daemons", "~> 1.1.0"
  spec.add_runtime_dependency "settingslogic", "~> 2.0.0"
  spec.add_runtime_dependency "aws-sdk-v1", "~> 1.60.0"
  spec.add_runtime_dependency "json", "~> 1.8.0"
end
