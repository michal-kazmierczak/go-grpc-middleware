# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module OpenTelemetryHelper
      def self.tracer
        OpenTelemetry.tracer_provider.tracer('grpc')
      end
    end
  end
end
