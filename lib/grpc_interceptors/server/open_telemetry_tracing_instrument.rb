# frozen_string_literal: true

require_relative '../common/grpc_helper'

module GrpcInterceptors
  module Server
    # https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/generic/interceptors.rb
    class OpenTelemetryTracingInstrument < ::GRPC::ServerInterceptor
      def request_response(request: nil, call: nil, method: nil)
        parent_context = OpenTelemetry.propagation.extract(call.metadata)
        route_name = GrpcHelper.route_name(method)
        attributes = tracing_attributes(method)
        kind = OpenTelemetry::Trace::SpanKind::SERVER
        span = GrpcHelper.tracer.start_span(
          route_name,
          with_parent: parent_context,
          attributes: attributes,
          kind: kind
        )

        yield

        span.finish
      rescue StandardError => e
        OpenTelemetry.handle_error(exception: e)

        raise e
      ensure
        span.finish if span.recording?
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
        {
          OpenTelemetry::SemanticConventions::Trace::RPC_SYSTEM => 'grpc',
          OpenTelemetry::SemanticConventions::Trace::RPC_SERVICE => method.owner.service_name,
          OpenTelemetry::SemanticConventions::Trace::RPC_METHOD => method.original_name.to_s,
        }
      end
    end
  end
end
