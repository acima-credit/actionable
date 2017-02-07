# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actionable/version'

Gem::Specification.new do |spec|
  spec.name    = 'actionable'
  spec.version = Actionable::VERSION
  spec.authors = ['Adrian Esteban Madrid']
  spec.email   = ['aemadrid@gmail.com']

  spec.summary     = %q{Simple and effective service objects.}
  spec.description = %q{Simple and effective Ruby service objects.}
  spec.homepage    = ''
  spec.license     = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'virtus', '>= 1.0.5'
  spec.add_dependency 'activemodel', '>= 4.1'
  spec.add_dependency 'activesupport', '>= 4.1'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'activerecord', '>= 4.1'
  spec.add_development_dependency 'sqlite3'
end
