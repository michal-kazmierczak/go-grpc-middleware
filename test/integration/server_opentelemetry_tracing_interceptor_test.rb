# frozen_string_literal: true

require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Server::OpenTelemetryTracingInterceptor do
  let(:otel_exporter) { OTEL_EXPORTER }
  let(:server_runner) do
    Support::GrpcServerRunner.new(
      server_opts: {
        interceptors: [
          GrpcInterceptors::Server::OpenTelemetryTracingInterceptor.new
        ]
      }
    )
  end

  before do
    server_port = server_runner.start
    @stub = Support::PingServer::Stub.new(
      "localhost:#{server_port}", :this_channel_is_insecure
    )
  end
  after do
    server_runner.stop
    otel_exporter.reset
  end

  describe '#request_response' do
    let(:ping_request) { Support::PingRequest.new }

    it 'records span' do
      response = @stub.request_response_ping(ping_request)

      assert_equal 1, otel_exporter.finished_spans.size
      assert_instance_of Support::PingResponse, response

      span = otel_exporter.finished_spans.first

      assert_equal '/support.PingServer/request_response_ping', span.name
      assert_equal :server, span.kind
      assert_equal 3, span.total_recorded_attributes
      assert_equal(
        {
          'rpc.system' => 'grpc',
          'rpc.service' => 'support.PingServer',
          'rpc.method' => 'request_response_ping' # TODO: shall this be camelized?
        },
        span.attributes
      )
    end

    it 'respects incoming context' do
      test_tracer.in_span('test-span') do
        ctx = {}
        OpenTelemetry.propagation.inject(ctx)
        @stub.request_response_ping(ping_request, metadata: ctx)
      end

      assert_equal 2, otel_exporter.finished_spans.size

      parent_span = otel_exporter.finished_spans.find { |s| s.kind == :internal }
      child_span = otel_exporter.finished_spans.find { |s| s.kind == :server }

      assert_equal parent_span.span_id, child_span.parent_span_id
    end
  end

  private

  def test_tracer
    OpenTelemetry.tracer_provider.tracer('test-tracer')
  end
end
