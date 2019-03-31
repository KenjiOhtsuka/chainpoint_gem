# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chainpoint/version'

Gem::Specification.new do |spec|
  spec.name          = 'chainpoint'
  spec.version       = Chainpoint::VERSION
  spec.date          = '2018-07-24'
  spec.authors       = ['Kenji Ohtsuka']
  spec.email         = ['kok.fdcm@gmail.com']

  spec.summary       = 'Chainpoint request library'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/KenjiOhtsuka/chainpoint_gem'

  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'msgpack'
  spec.required_ruby_version = '>= 2.5.0'

  spec.license = 'GPL-3.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
