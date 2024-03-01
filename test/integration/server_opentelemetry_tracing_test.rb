# frozen_string_literal: true

require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Server::OpenTelemetryTracingInstrument do
  let(:exporter) { EXPORTER }
  let(:server_runner) do
    Support::GrpcServerRunner.new(
      server_opts: {
        interceptors: [
          GrpcInterceptors::Server::OpenTelemetryTracingInstrument.new
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
    exporter.reset
  end

  describe '#request_response' do
    let(:ping_request) { Support::PingRequest.new }

    it 'records span' do
      @stub.request_response_ping(ping_request)

      expect(exporter.finished_spans.size).must_equal(1)

      span = exporter.finished_spans.first
      expect(span.name).must_equal('/support.PingServer/request_response_ping')
      expect(span.kind).must_equal(:server)
      expect(span.total_recorded_attributes).must_equal(3)
      expect(span.attributes).must_equal(
        {
          'rpc.system' => 'grpc',
          'rpc.service' => 'support.PingServer',
          'rpc.method' => 'request_response_ping' # TODO: shall this me camelized?
        }
      )
    end

    it 'respects incoming context' do
      test_tracer.in_span('test-span') do
        ctx = {}
        OpenTelemetry.propagation.inject(ctx)
        @stub.request_response_ping(ping_request, metadata: ctx)
      end

      expect(exporter.finished_spans.size).must_equal(2)

      parent_span = exporter.finished_spans.find{ |s| s.kind == :internal }
      child_span = exporter.finished_spans.find{ |s| s.kind == :server }
      expect(child_span.parent_span_id).must_equal(parent_span.span_id)
    end
  end

  private

  def test_tracer
    OpenTelemetry.tracer_provider.tracer('test-tracer')
  end
end
