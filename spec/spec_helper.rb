# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter %w[lib/netomox/diff_view/ lib/netomox/graphdb/]
end

require 'bundler/setup'
require 'netomox'
require 'json'

# ref. https://gist.github.com/herrphon/2d2ebbf23c86a10aa955
module IOHelper
  def capture
    begin
      $stdout = StringIO.new
      $stderr = StringIO.new
      yield
      result = {}
      result[:stdout] = $stdout.string
      result[:stderr] = $stderr.string
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end
    result
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # stdout/stderr capture helper
  config.include IOHelper
end
