# frozen_string_literal: true

module GrpcInterceptors
  module Server
    class StatsDMetrics < ::GRPC::ServerInterceptor
      def request_response(request: nil, call: nil, method: nil, metadata: nil)
        start_time = Time.now
        code = GRPC::Core::StatusCodes::OK
        labels = common_labels(method)
        labels[:grpc_type] = 'unary'

        yield
      rescue StandardError => e
        code = e.is_a?(GRPC::BadStatus) ? e.code : GRPC::Core::StatusCodes::UNKNOWN
        raise
      ensure
        labels.merge(grpc_code: code)
        elapsed_time = Time.now - start_time
        StatsD.histogram('grpc_latency_seconds', elapsed_time, tags: labels)
      end

      # def server_streamer(_request: nil, call: nil, method: nil, &block)
      # end

      # def client_streamer(call: nil, method: nil, &block)
      # end

      # def bidi_streamer(_request: nil, call: nil, method: nil, &block)
      # end

      private

      def common_labels(method)
        {
          grpc_method: method.original_name.to_s,
          grpc_service: method.owner.service_name
        }
      end
    end
  end
end
