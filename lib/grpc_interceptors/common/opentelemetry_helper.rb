# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module OpenTelemetryHelper
      def self.tracer
        OpenTelemetry.tracer_provider.tracer('grpc')
      end

      def self.tracing_attributes(method)
        service_name = Common::GrpcHelper.service_name(method)
        method_name = Common::GrpcHelper.method_name(method)

        {
          OpenTelemetry::SemanticConventions::Trace::RPC_SYSTEM => 'grpc',
          OpenTelemetry::SemanticConventions::Trace::RPC_SERVICE => service_name,
          OpenTelemetry::SemanticConventions::Trace::RPC_METHOD => method_name
        }
      end
    end
  end
end
