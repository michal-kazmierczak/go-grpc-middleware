# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default, :development, :test)

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!
# require 'webmock/minitest'

Dir['./lib/**/*.rb'].each { |file| require file }

OTEL_EXPORTER = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
span_processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(OTEL_EXPORTER)

OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(span_processor)
end

# it will swallow all calls, but allows you to capture them for testing purposes
ENV['STATSD_ENV'] = 'test'
require 'statsd-instrument'
