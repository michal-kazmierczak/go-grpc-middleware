# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/logging'

module GrpcInterceptors
  module Server
    class LoggingInterceptor < ::GRPC::ServerInterceptor
      def initialize(logger)
        @logger = logger

        super()
      end

      def request_response(request: nil, call: nil, method: nil, &block)
        Common::Logging.yield_and_log(
          logger: @logger, request: request, method: method,
          method_type: 'unary', kind: KIND, &block
        )
      end

      # def client_streamer(call: nil, method: nil)
      #  yield
      # end

      # def server_streamer(_request: nil, call: nil, method: nil)
      #  yield
      # end

      # def bidi_streamer(_requests: nil, call: nil, method: nil)
      #  yield
      # end
    end
  end
end
