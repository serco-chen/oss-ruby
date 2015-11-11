# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oss/version'

Gem::Specification.new do |spec|
  spec.name          = "oss-ruby"
  spec.version       = OSS::VERSION
  spec.authors       = ["Xiaoguang Chen"]
  spec.email         = ["xg.chen87@gmail.com"]
  spec.summary       = "Ruby SDK for Aliyun OSS"
  spec.description   = %q{Ruby SDK for Aliyun OSS.}
  spec.homepage      = "https://github.com/serco-chen/oss-ruby"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0") - %w[.gitignore]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.9.0'
  spec.add_dependency 'nokogiri', '~> 1.6.6'
  spec.add_dependency 'mime-types', '~> 2.6'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
