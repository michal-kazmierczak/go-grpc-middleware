require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Client::OpenTelemetryTracingInstrument do
  let(:exporter) { EXPORTER }
  let(:server_runner) do
    Support::GrpcServerRunner.new
  end

  before do
    server_port = server_runner.start

    @stub = Support::PingServer::Stub.new(
      "localhost:#{server_port}",
      :this_channel_is_insecure,
      interceptors: [
        GrpcInterceptors::Client::OpenTelemetryTracingInstrument.new
      ]
    )
  end
  after do
    server_runner.stop
    exporter.reset
  end

  describe "#request_response" do
    it 'records span' do
      ping_request = Support::PingRequest.new
      result = @stub.request_response_ping(ping_request)

      expect(exporter.finished_spans.size).must_equal(1)

      span = exporter.finished_spans.first
      expect(span.name).must_equal('/support.PingServer/RequestResponsePing')
      expect(span.kind).must_equal(:client)
      expect(span.total_recorded_attributes).must_equal(3)
      expect(span.attributes).must_equal(
        {
          "rpc.system" => "grpc",
          "rpc.service" => "support.PingServer",
          "rpc.method"=>"RequestResponsePing"
        }
      )
    end
  end
end
