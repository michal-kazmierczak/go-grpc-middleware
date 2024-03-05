# ruby-grpc-interceptors

A collection of Ruby interceptors (middlewares) for gRPC servers and clients.

Heavily inspired by [grpc-ecosystem/go-grpc-middleware](https://github.com/grpc-ecosystem/go-grpc-middleware). The motivation is to have a unified behavior of gRPC services and integrated telemetry data (logging, tracing and metrics) regardless of the used language.

## Contents

- [Server](#server)
  - [Error handling](#error-handling)
  - [Logging](#logging)
  - [StatsD metrics](#statsd-metrics)
  - [OpenTelemetry tracing](#opentelemetry-tracing)
- [Client](#client)
  - [Logging](#logging-1)
  - [OpenTelemetry tracing](#opentelemetry-tracing)
  - [Retry mechanism](#rety-mechanism)

## Server

The order of interceptors matters. Considering all server interceptors, the correct way of installation is:

```ruby
```

### Error handling

_WIP_

### Logging

When the `LOG_LEVEL` env variable is set to `INFO` then the server logs out.

When the `LOG_LEVEL` env variable is set to `DEBUG` then the server additionally adds the request to the log message. (Note, adding the response is currently blocked by [this gRPC issue](https://github.com/grpc/grpc/pull/26547).)



### StatsD metrics

```ruby
GRPC::RpcServer.new(
  interceptors: [
    GrpcInterceptors::Server::StatsDMetrics.new
  ]
)
```

The server emits a histogram metric called `grpc_latency_seconds` with the following tags:

 - `grpc_method` representing the called method
 - `grpc_service` representing the service
 - `grpc_type` representing the gRPC kind of method

#### [Experimental] A gauge metric of the server jobs queue
```
# https://github.com/grpc/grpc/blob/v1.62.0/src/ruby/lib/grpc/generic/rpc_server.rb#L43C9-L43C21
server.instance_variable_get(:@pool).jobs_waiting
```

### OpenTelemetry tracing

```ruby
GRPC::RpcServer.new(
  interceptors: [
    GrpcInterceptors::Server::OpenTelemetryTracingInstrument.new
  ]
)
```

## Client

### Logging

### OpenTelemetry tracing

```ruby
GRPC::RpcServer.new(
  interceptors: [
    GrpcInterceptors::Client::OpenTelemetryTracingInstrument.new
  ]
)
```

## Development

### Integration tests

Integration tests require some infrastructure to mimic gRPC client and server. For this purpose, there's a simple service definition in the `test/integration/support/ping.proto`. To re-generate `*_pb.rb` files run `bundle exec rake proto:generate`.

### Releasing

```
bundle exec rake build
bundle exec rake release
```
