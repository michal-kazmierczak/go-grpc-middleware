# frozen_string_literal: true

require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Client::OpenTelemetryTracingInterceptor do
  let(:otel_exporter) { OTEL_EXPORTER }
  let(:server_runner) do
    Support::GrpcServerRunner.new
  end

  before do
    server_port = server_runner.start

    @stub = Support::PingServer::Stub.new(
      "localhost:#{server_port}",
      :this_channel_is_insecure,
      interceptors: [
        GrpcInterceptors::Client::OpenTelemetryTracingInterceptor.new
      ]
    )
  end
  after do
    server_runner.stop
    otel_exporter.reset
  end

  describe '#request_response' do
    let(:ping_request) { Support::PingRequest.new }

    it 'records span' do
      @stub.request_response_ping(ping_request)

      assert_equal 1, otel_exporter.finished_spans.size

      span = otel_exporter.finished_spans.first

      assert_equal '/support.PingServer/RequestResponsePing', span.name
      assert_equal :client, span.kind
      assert_equal 3, span.total_recorded_attributes
      assert_equal(
        {
          'rpc.system' => 'grpc',
          'rpc.service' => 'support.PingServer',
          'rpc.method' => 'RequestResponsePing'
        },
        span.attributes
      )
    end
  end
end
