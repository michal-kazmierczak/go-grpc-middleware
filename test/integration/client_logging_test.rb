# frozen_string_literal: true

require 'test_helper'
require_relative '../support/ping_server_impl'
require_relative '../support/grpc_server_runner'

describe GrpcInterceptors::Client::Logging do
  let(:log) { StringIO.new }
  let(:logger) do
    Logger.new(log, level: Logger::INFO, formatter: method(:formatter_helper))
  end
  let(:received_log) { JSON(log.string) }

  let(:server_runner) do
    Support::GrpcServerRunner.new
  end

  before do
    @server_port = server_runner.start
    @stub = Support::PingServer::Stub.new(
      "localhost:#{@server_port}",
      :this_channel_is_insecure,
      interceptors: [
        GrpcInterceptors::Client::Logging.new(logger)
      ]
    )
  end
  after do
    server_runner.stop
  end

  describe 'when logger level is INFO' do
    let(:ping_request) { Support::PingRequest.new(value: 'Ping') }

    it 'produces log with basic facts' do
      response = @stub.request_response_ping(ping_request)

      assert_instance_of Support::PingResponse, response
      assert_instance_of Integer, received_log['pid']
      assert_equal 'client', received_log['grpc.component']
      assert_equal 'support.PingServer', received_log['grpc.service']
      assert_equal 'RequestResponsePing', received_log['grpc.method']
      assert_equal 'unary', received_log['grpc.method_type']
      assert_equal 0, received_log['grpc.code']
      refute received_log.key?('backtrace')
      refute received_log.key?('error')
    end

    describe 'when tracing is enabled' do
      let(:otel_exporter) { OTEL_EXPORTER }
      before do
        @stub = Support::PingServer::Stub.new(
          "localhost:#{@server_port}",
          :this_channel_is_insecure,
          interceptors: [ # the order of interceptors matters
            GrpcInterceptors::Client::Logging.new(logger),
            GrpcInterceptors::Client::OpenTelemetryTracingInstrument.new
          ]
        )
      end
      after { otel_exporter.reset }

      it 'produces log with non-empty trace_id and span_id' do
        @stub.request_response_ping(ping_request)

        refute_nil received_log['span_id']
        refute_nil received_log['trace_id']
        refute_equal '0' * 16, received_log['span_id']
        refute_equal '0' * 32, received_log['trace_id']
      end
    end
  end

  describe 'when logger level is DEBUG' do
    let(:ping_request) { Support::PingRequest.new(value: 'Ping') }

    it 'produces log as on the INFO level plus request and response' do
      logger.level = Logger::DEBUG
      response = @stub.request_response_ping(ping_request)

      assert_instance_of Support::PingResponse, response
      assert_instance_of Integer, received_log['pid']
      assert_equal 'client', received_log['grpc.component']
      assert_equal 'support.PingServer', received_log['grpc.service']
      assert_equal 'RequestResponsePing', received_log['grpc.method']
      assert_equal 'unary', received_log['grpc.method_type']
      assert_equal 0, received_log['grpc.code']
      refute received_log.key?('backtrace')
      refute received_log.key?('error')

      logged_request = JSON(received_log['request'])
      logged_response = JSON(received_log['response'])

      assert_equal 'Ping', logged_request['value']
      assert_equal 'Pong!', logged_response['value']
    end
  end

  private

  def formatter_helper(_severity, _datetime, _progname, msg)
    JSON.dump(msg)
  end
end
