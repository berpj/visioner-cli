# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'visioner/version'

Gem::Specification.new do |spec|
  spec.name          = "visioner"
  spec.version       = Visioner::VERSION
  spec.authors       = ["Pierre-Jean Bergeron"]
  spec.email         = ["pj@bergeron.io"]

  spec.summary       = %q{Automatically rename your pictures using Google Vision API and metadata.}
  spec.homepage      = "https://github.com/berpj/visioner"
  spec.license       = "MIT"

  #spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files += Dir['lib/**/*']
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "exifr", "~> 1.2"
end
