# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/log_payload'

module GrpcInterceptors
  module Server
    class Logging < ::GRPC::ServerInterceptor
      def initialize(logger)
        @logger = logger

        super()
      end

      def request_response(request: nil, call: nil, method: nil, &block)
        log(request, method, 'unary', &block)
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

      private

      # in case of an exception, it logs out on the ERROR level including error details
      # if the current level is INFO, then it logs out basic facts
      # if the current level is DEBUG, then it additionally includes the request
      def log(request, method, method_type)
        grpc_code = ::GRPC::Core::StatusCodes::OK

        yield
      rescue StandardError => e
        grpc_code = e.is_a?(::GRPC::BadStatus) ? e.code : ::GRPC::Core::StatusCodes::UNKNOWN

        raise
      ensure
        payload = Common::LogPayload.build(
          method, method_type, grpc_code, 'server'
        )

        if e
          payload['error'] = e.class.to_s
          payload['error_message'] = e.message
          payload['backtrace'] = e.backtrace
          @logger.error(payload)
        elsif @logger.level == Logger::Severity::INFO
          @logger.info(payload)
        elsif @logger.level == Logger::Severity::DEBUG
          payload['request'] = Common::GrpcHelper.proto_to_json(request)
          @logger.debug(payload)
        end
      end
    end
  end
end
