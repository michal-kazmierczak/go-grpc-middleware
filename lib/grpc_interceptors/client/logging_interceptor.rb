# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/logging'

module GrpcInterceptors
  module Client
    class LoggingInterceptor < ::GRPC::ClientInterceptor

      def initialize(logger)
        @logger = logger

        super()
      end

      def request_response(
        request: nil, call: nil, method: nil, metadata: nil, &block
      )
        Common::Logging.yield_and_log(
          logger: @logger, request: request, method: method,
          method_type: 'unary', kind: KIND, &block
        )
      end

      def client_streamer(
        requests: nil, call: nil, method: nil, metadata: nil, &block
      )
        requests.each do |request|
          Common::Logging.log(request: request, method: method, method_type: 'client_stream')
        end

        Common::Logging.yield_and_log(method: method, method_type: 'client_stream', &block)
      end

      # def server_streamer(_request: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end

      # def bidi_streamer(_requests: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end
    end
  end
end
