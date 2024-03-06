# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'grpc_interceptors'
  spec.version = '0.1.3'
  spec.authors = ['michal-kazmierczak']
  spec.homepage = 'https://github.com/michal-kazmierczak/ruby-grpc-interceptors'
  spec.summary = 'A collection of Ruby interceptors (middlewares) for gRPC servers and clients.'
  spec.description = 'A collection of Ruby interceptors (middlewares) for gRPC servers and clients.'
  spec.license = 'MIT'

  spec.files = Dir.glob('lib/**/*.rb') + Dir.glob('*.md') + ['LICENSE']
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency 'opentelemetry-api', '>=  1.0.0'
  spec.add_dependency 'opentelemetry-instrumentation-base', '~> 0.22.3'
  spec.add_dependency 'statsd-instrument', '~> 3.6'

  spec.add_development_dependency 'grpc', '1.61'
  spec.add_development_dependency 'grpc-tools', '1.61'
  spec.add_development_dependency 'guard', '~> 2.18'
  spec.add_development_dependency 'guard-minitest', '~> 2.4'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.6.1'
  spec.add_development_dependency 'opentelemetry-sdk', '~> 1.0'
  spec.add_development_dependency 'opentelemetry-test-helpers'
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.60.1'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.34.5'
  spec.add_development_dependency 'rubocop-performance', '~> 1.20'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
