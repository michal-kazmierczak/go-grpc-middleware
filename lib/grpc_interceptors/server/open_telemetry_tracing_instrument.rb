# frozen_string_literal: true

require_relative '../common/grpc_helper'

module GrpcInterceptors
  module Server
    # https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/generic/interceptors.rb
    class OpenTelemetryTracingInstrument < ::GRPC::ServerInterceptor
      def request_response(request: nil, call: nil, method: nil, &block)
        context = OpenTelemetry.propagation.extract(call.metadata)
        route_name = Common::GrpcHelper.route_name_from_server(method)
        attributes = tracing_attributes(method)
        kind = OpenTelemetry::Trace::SpanKind::SERVER

        OpenTelemetry::Context.with_current(context) do
          Common::OpenTelemetryHelper.tracer.in_span(
            route_name,
            attributes: attributes,
            kind: kind,
            &block
          )
        end
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

      def tracing_attributes(method)
        service_name = Common::GrpcHelper.service_name_from_server(method)
        method_name = Common::GrpcHelper.method_name_from_server(method)

        {
          OpenTelemetry::SemanticConventions::Trace::RPC_SYSTEM => 'grpc',
          OpenTelemetry::SemanticConventions::Trace::RPC_SERVICE => service_name,
          OpenTelemetry::SemanticConventions::Trace::RPC_METHOD => method_name
        }
      end
    end
  end
end
