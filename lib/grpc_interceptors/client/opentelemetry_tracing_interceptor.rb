# frozen_string_literal: true

require_relative '../common/grpc_helper'
require_relative '../common/opentelemetry_helper'

module GrpcInterceptors
  module Client
    class OpenTelemetryTracingInterceptor < ::GRPC::ClientInterceptor
      def request_response(request: nil, call: nil, method: nil, metadata: nil)
        attributes = Common::OpenTelemetryHelper.tracing_attributes(method)

        Common::OpenTelemetryHelper.tracer.in_span(
          method, kind: KIND, attributes: attributes
        ) do
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
    end
  end
end
