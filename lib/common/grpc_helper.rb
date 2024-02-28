# frozen_string_literal: true

module GrpcInterceptors
  module GrpcHelper
    def self.route_name(method)
      "/#{method.owner.service_name}/#{method.original_name}"
    end

    def self.tracer
      OpenTelemetry.tracer_provider.tracer('grpc')
    end
  end
end
