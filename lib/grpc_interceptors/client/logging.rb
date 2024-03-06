# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/log_payload'

module GrpcInterceptors
  module Client
    class Logging < ::GRPC::ServerInterceptor
      def initialize(logger)
        @logger = logger

        super()
      end

      def request_response(
        request: nil, call: nil, method: nil, metadata: nil, &block
      )
        log(request, method, 'unary', &block)
      end

      # def client_streamer(_requests: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end

      # def server_streamer(_request: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end

      # def bidi_streamer(_requests: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end

      private

      # if the server responds with error, then the error is attached to the log
      # if the current level is INFO, then it logs out basic facts
      # if the current level is DEBUG, then it additionally includes the request
      def log(request, method, method_type)
        grpc_code = ::GRPC::Core::StatusCodes::OK

        response = yield
      rescue StandardError => e
        grpc_code = e.is_a?(::GRPC::BadStatus) ? e.code : ::GRPC::Core::StatusCodes::UNKNOWN

        raise
      ensure
        payload = Common::LogPayload.build(
          method, method_type, grpc_code, 'client'
        )

        if e
          payload['error'] = e.class.to_s
          payload['error_message'] = e.message
          payload['backtrace'] = e.backtrace
        end

        if @logger.level == Logger::Severity::INFO
          @logger.info(payload)
        elsif @logger.level == Logger::Severity::DEBUG
          payload['request'] = Common::GrpcHelper.proto_to_json(request)
          payload['response'] = Common::GrpcHelper.proto_to_json(response)
          @logger.debug(payload)
        end
      end
    end
  end
end
