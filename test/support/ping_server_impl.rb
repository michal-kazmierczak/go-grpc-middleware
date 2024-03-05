require_relative 'proto/ping_services_pb'

# inspired by https://ieftimov.com/posts/creating-testing-grpc-server-interceptors-ruby/#service-implementation
class PingServerImpl < Support::PingServer::Service
  include Support

  def request_response_ping(ping_request, _call)
    raise_exception(ping_request)

    PingResponse.new(value: 'Pong!')
  end

  def client_streamer_ping(call)
    call.each_remote_read do |ping_request|
      raise_exception(ping_request)
    end
  end

  def server_stream_ping(ping_request, _call)
    raise_exception(ping_request)

    [PingResponse.new(value: 'Pong!')].each
  end

  def bidi_stream_method(call, _view)
    call.each do |ping_request|
      raise_exception(ping_request)
    end

    [PingResponse.new(name: 'Pong!')].each
  end

  private

  def raise_exception(ping_request)
    code = ping_request.error_code

    if code > ::GRPC::Core::StatusCodes::OK
      raise ::GRPC::BadStatus.new_status_exception(code, 'test exception')
    elsif code < ::GRPC::Core::StatusCodes::OK
      raise StandardError, code.to_s
    end
  end
end
