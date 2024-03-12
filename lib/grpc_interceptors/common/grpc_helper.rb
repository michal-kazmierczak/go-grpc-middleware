# frozen_string_literal: true

module GrpcInterceptors
  module Common
    module GrpcHelper
      def self.route_name(method)
        return method unless method.is_a?(Method) # client case

        # server case
        service_name = service_name_from_server(method)
        method_name = method_name_from_server(method)

        "/#{service_name}/#{method_name}"
      end

      def self.service_name(method)
        return service_name_from_server(method) if method.is_a?(Method) # server case

        service_name_from_client(method) # client case
      end

      def self.method_name(method)
        return method_name_from_server(method) if method.is_a?(Method) # server case

        method_name_from_client(method) # client case
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

      # converts proto message to a Ruby hash preserving the original fields' names
      # and including default values
      # WARNING! It can be slow and not 100% accurate. In this gem it's only used in the DEBUG mode
      # related comment: https://github.com/protocolbuffers/protobuf/issues/6755#issuecomment-733880977
      def self.proto_to_h(proto)
        JSON(
          proto.to_json(
            emit_defaults: true,
            preserve_proto_fieldnames: true
          )
        )
      end
    end
  end
end
