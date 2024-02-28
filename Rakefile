# frozen_string_literal: true

require 'minitest/test_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Minitest::TestTask.create(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.warning = false
  t.test_globs = ['test/**/*_test.rb']
end

namespace :proto do
  desc 'Generate test protobuf stubs'
  task :generate do |_task, _args|
    system 'bundle exec grpc_tools_ruby_protoc'\
           ' --ruby_out=.'\
           ' --grpc_out=.'\
           ' ./test/integration/support/proto/ping.proto'
    # sed -E -i '' "s/require .*\/(.*_pb)'/require_relative '\1'/g" test/integration/support/proto/ping_services_pb.rb
  end

  desc 'Generate test protobuf stubs'
  task :lint do |_task, _args|
    # make sure that you have the buf binary installed https://buf.build/
    system 'buf lint test/integration/support/ping.proto'
  end
end

task default: %i[test rubocop proto:lint]
