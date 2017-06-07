Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-elasticsearch-timestamp-check"
  spec.version       = "0.2.2"
  spec.authors       = ["Richard Li"]
  spec.email         = ["evilcat@wisewolfsolutions.com"]
  spec.description   = %q{fluent filter plugin to ensure @timestamp is in proper format}
  spec.summary       = %q{fluent timestamp checker filter}
  spec.homepage      = "https://github.com/ecwws/fluent-plugin-elasticsearch-timestamp-check"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
end
