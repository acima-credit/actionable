# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actionable/version'

Gem::Specification.new do |spec|
  spec.name = 'actionable'
  current_branch = `git branch --remote --contains | sed "s|[[:space:]]*origin/||"`.strip
  branch_commit = `git rev-parse HEAD`.strip[0..6]
  spec.version = current_branch == 'master' ? Actionable::VERSION : "#{Actionable::VERSION}-#{branch_commit}"
  spec.authors = ['Adrian Esteban Madrid']
  spec.email   = ['aemadrid@gmail.com']

  spec.summary     = 'Simple and effective service objects.'
  spec.description = 'Simple and effective Ruby service objects.'
  spec.homepage    = ''
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/acima-credit'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 4.1'
  spec.add_dependency 'activesupport', '>= 4.1'

  spec.add_development_dependency 'activerecord', '>= 4.1'
  spec.add_development_dependency 'bundler', '> 1.14'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
