# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netomox/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.1.0'

  spec.name          = 'netomox'
  spec.version       = Netomox::VERSION
  spec.authors       = ['corestate55']
  spec.email         = ['manabu.hagiwara@okinawaopenlabs.org']

  spec.summary       = 'Network Topology Modeling Toolbox'
  spec.description   = 'Tools for build/validate RFC8345-based network topology data.'
  spec.homepage      = 'https://github.com/ool-mddo/netomox'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/ool-mddo'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'hashdiff', '~> 1.0.1'
  spec.add_runtime_dependency 'jsonpath', '~> 1.1.2'
  spec.add_runtime_dependency 'neography', '~> 1.8.0'
  spec.add_runtime_dependency 'termcolor', '~> 1.2.2'
  spec.add_runtime_dependency 'thor', '~> 1.2.1'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 11.1.1'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rubocop', '~> 1.37'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.13'
  spec.add_development_dependency 'simplecov', '~> 0.21.0'
  spec.add_development_dependency 'yard', '~> 0.9.20'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
