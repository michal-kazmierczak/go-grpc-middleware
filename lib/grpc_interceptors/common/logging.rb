# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module Logging

      def self.yield_and_log(
        logger: nil, request: nil, method: nil, method_type: nil, kind: nil
      )
        grpc_code = ::GRPC::Core::StatusCodes::OK
        response = yield
      rescue StandardError => e
        grpc_code = e.is_a?(::GRPC::BadStatus) ? e.code : ::GRPC::Core::StatusCodes::UNKNOWN
        extra_fields = {
          'error' => e.class.to_s,
          'error_message' => e.message,
          'backtrace' => e.backtrace
        }

        raise
      ensure
        extra_fields ||= {}
        extra_fields['grpc.code'] = grpc_code

        if logger.level == ::Logger::Severity::DEBUG && !response.nil?
          extra_fields['response'] = Common::GrpcHelper.proto_to_h(response)
        end

        log(
          logger: logger, request: request, method: method,
          method_type: method_type, kind: kind, extra_fields: extra_fields
        )
      end

      ##
      # Log a gRPC interaction.
      #
      # If the current log level is INFO, then it logs out basic facts.
      # If the current log level is DEBUG, then it additionally adds to the log request and response.
      # If the server responds with error, then the error is added to the log.
      #
      # @param [Object] request The request object
      # @param [String] method The method passed to the intercepting function
      # @param [String] method_type The used method_type, unary or one of the streams
      #
      def self.log(
        logger: nil, request: nil, method: nil, method_type: nil, kind: nil,
        extra_fields: {}
      )
        payload = build_payload(method, method_type, kind)
        payload.merge!(extra_fields)

        if logger.level == ::Logger::Severity::INFO
          logger.info(payload)
        elsif logger.level == ::Logger::Severity::DEBUG
          payload['request'] = Common::GrpcHelper.proto_to_h(request) unless request.nil?
          logger.debug(payload)
        end
      end

      def self.build_payload(method, method_type, kind)
        service = GrpcHelper.service_name(method)
        method = GrpcHelper.method_name(method)

        payload = {
          'pid' => Process.pid,
          'grpc.component' => kind, # the caller, server or client
          'grpc.service' => service,
          'grpc.method' => method,
          'grpc.method_type' => method_type
        }

        if defined?(OpenTelemetry) && OpenTelemetry::Trace.current_span.recording?
          tracing_context = OpenTelemetry::Trace.current_span.context
          payload['span_id'] = tracing_context.hex_span_id
          payload['trace_id'] = tracing_context.hex_trace_id
        end

        payload
      end
    end
  end
end
