# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module GrpcHelper
      def self.route_name_from_server(method)
        service_name = service_name_from_server(method)
        method_name = method_name_from_server(method)

        "/#{service_name}/#{method_name}"
      end

      def self.service_name_from_server(method)
        method.owner.service_name.to_s
      end

      def self.method_name_from_server(method)
        method.original_name.to_s
      end

      def self.service_name_from_client(method)
        method_parts = method.to_s.sub(%r{^/}, '').split('/')
        method_parts.first
      end

      def self.method_name_from_client(method)
        method_parts = method.to_s.sub(%r{^/}, '').split('/')
        method_parts[1..].join('/')
      end

      def self.proto_to_json(proto)
        proto.to_json(
          emit_defaults: true,
          preserve_proto_fieldnames: true
        )
      end
    end
  end
end
