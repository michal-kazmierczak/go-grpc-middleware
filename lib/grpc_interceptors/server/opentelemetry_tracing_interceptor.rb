# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/opentelemetry_helper'

module GrpcInterceptors
  module Server
    # https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/generic/interceptors.rb
    class OpenTelemetryTracingInterceptor < ::GRPC::ServerInterceptor
      def request_response(request: nil, call: nil, method: nil, &block)
        context = OpenTelemetry.propagation.extract(call.metadata)
        route_name = Common::GrpcHelper.route_name(method)
        attributes = Common::OpenTelemetryHelper.tracing_attributes(method)

        OpenTelemetry::Context.with_current(context) do
          Common::OpenTelemetryHelper.tracer.in_span(
            route_name,
            attributes: attributes,
            kind: KIND,
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
    end
  end
end
