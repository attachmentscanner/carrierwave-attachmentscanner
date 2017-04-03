# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/attachmentscanner/version'

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-attachmentscanner"
  spec.version       = CarrierWave::AttachmentScanner::VERSION
  spec.authors       = ["Steve Smith"]
  spec.email         = ["gems@dynedge.co.uk"]

  spec.summary       = %q{Scan carrierwave attachments using AttachmentScanner}
  spec.description   = %q{Automatically sends carrierwave uploads to AttachmentScanner to search for
    viruses, malware and other malicious files. }
  spec.homepage      = "http://www.attachmentscanner.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "carrierwave"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
