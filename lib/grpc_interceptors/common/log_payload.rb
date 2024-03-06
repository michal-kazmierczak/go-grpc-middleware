# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module LogPayload
      def self.build(method, method_type, grpc_code, kind)
        service = GrpcHelper.service_name(method)
        method = GrpcHelper.method_name(method)

        payload = {
          'pid' => Process.pid,
          'grpc.component' => kind, # the caller, server or client
          'grpc.service' => service,
          'grpc.method' => method,
          'grpc.method_type' => method_type,
          'grpc.code' => grpc_code
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
