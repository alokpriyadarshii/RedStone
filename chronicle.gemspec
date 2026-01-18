# frozen_string_literal: true

require_relative 'lib/chronicle/version'

Gem::Specification.new do |spec|
  spec.name          = 'chronicle'
  spec.version       = Chronicle::VERSION
  spec.authors       = ['Your Name']
  spec.email         = ['you@example.com']

  spec.summary       = 'A tiny JSONL journal + CLI (production-grade Ruby template).'
  spec.description   = 'Chronicle is a tiny, dependency-free journal library with a practical CLI.'
  spec.homepage      = 'https://example.com/chronicle'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    Dir[
      'README.md',
      'LICENSE',
      'CHANGELOG.md',
      'bin/*',
      'lib/**/*.rb',
      'test/**/*.rb',
      '.github/workflows/*.yml'
    ]
  end

  spec.bindir = 'bin'
  spec.executables = ['chronicle']
  spec.require_paths = ['lib']
  spec.add_dependency 'ostruct'
end
