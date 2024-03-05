# frozen_string_literal: true

require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Server::StatsDMetrics do
  include StatsD::Instrument::Assertions

  let(:server_runner) do
    Support::GrpcServerRunner.new(
      server_opts: {
        interceptors: [
          GrpcInterceptors::Server::StatsDMetrics.new
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
  end

  describe '#request_response' do
    it 'emits histogram metric' do
      ping_request = Support::PingRequest.new
      metrics = capture_statsd_calls do
        @stub.request_response_ping(ping_request)
      end

      assert_equal 1, metrics.length
      assert_equal 'grpc_latency_seconds', metrics.first.name
      assert_equal(
        [
          'grpc_method:request_response_ping',
          'grpc_service:support.PingServer',
          'grpc_type:unary'
        ],
        metrics.first.tags
      )
    end
  end
end
