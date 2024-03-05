# frozen_string_literal: true

require_relative '../common/grpc_helper'

module GrpcInterceptors
  module Client
    class OpenTelemetryTracingInstrument < ::GRPC::ClientInterceptor
      def request_response(request: nil, call: nil, method: nil, metadata: nil)
        kind = OpenTelemetry::Trace::SpanKind::CLIENT
        attributes = tracing_attributes(method)

        Common::OpenTelemetryHelper.tracer.in_span(method, kind: kind, attributes: attributes) do
          OpenTelemetry.propagation.inject(metadata)
          yield
        end
      end

      # def client_streamer(_requests: nil, call: nil, method: nil, metadata: nil)
      #  yield
      # end

      # def server_streamer(_request: nil, call: nil, method: nil, metadata: nil)
      #   yield
      # end

      # def bidi_streamer(_requests: nil, call: nil, method: nil, metadata: nil)
      # yield
      # end

      private

      def tracing_attributes(method)
        service_name = Common::GrpcHelper.service_name_from_client(method)
        method_name = Common::GrpcHelper.method_name_from_client(method)

        {
          OpenTelemetry::SemanticConventions::Trace::RPC_SYSTEM => 'grpc',
          OpenTelemetry::SemanticConventions::Trace::RPC_SERVICE => service_name,
          OpenTelemetry::SemanticConventions::Trace::RPC_METHOD => method_name
        }
      end
    end
  end
end
