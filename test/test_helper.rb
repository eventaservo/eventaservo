# frozen_string_literal: true

if ENV["CI"]
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.start "rails" do
    add_filter "/test/"
    add_filter "/config/"
    # Keep every worker's resultset entry mergeable when the parent collates them.
    merge_timeout 3600
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::CoberturaFormatter
    ])
  end
end

ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/mock"
require "debug"
require "geocoder"
require_relative "support/geocoder_stub"
require_relative "support/timezone_stub"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  if ENV["CI"]
    # Rails forks one process per worker (ActiveSupport::Testing::Parallelization).
    # Coverage tracking is inherited across the fork, but Ruby's Coverage counters
    # are re-initialized in the child, so every worker measures its own slice.
    #
    # The forked workers never reach SimpleCov's own `at_exit` reporter, because
    # `SimpleCov.at_exit_behavior` bails out as soon as `SimpleCov.pid != Process.pid`.
    # Without an explicit hand-off, the 16 workers overwrite each other in the same
    # "Minitest" key of .resultset.json and the report ends up holding a single
    # worker's slice of the suite (~38% instead of ~85%).
    #
    # Fix: give each worker its own resultset key/directory in `parallelize_setup`,
    # make it persist its raw result in `parallelize_teardown` (the last hook that
    # runs inside the forked child), and let the parent collate every worker's
    # resultset together with its own pre-fork result into the final report.
    #
    # The parent's own result matters: with CI=true the app eager-loads before forking,
    # so the parent holds the load-time hits (class bodies, `def` lines, macros) that
    # no worker can re-measure, since every worker starts from zeroed counters.
    # Dropping it would silently lose that coverage.
    parallelize_setup do |worker|
      SimpleCov.command_name("Minitest (worker #{worker})")
      SimpleCov.coverage_dir("coverage/resultsets/#{worker}")
    end

    parallelize_teardown do |worker|
      # Persist this worker's raw coverage. The worker is about to exit, so
      # bypassing `SimpleCov.result` (which would merge and format) is safe and
      # keeps every worker from rewriting the shared HTML/Cobertura reports.
      worker_result = SimpleCov::Result.new(
        SimpleCov::ResultAdapter.call(Coverage.result),
        command_name: "Minitest (worker #{worker})"
      )
      SimpleCov::ResultMerger.store_result(worker_result)
    end

    # Absolute coverage/ directory, captured before any per-worker override.
    base_coverage_dir = SimpleCov.coverage_path

    at_exit do
      # Every forked worker inherits this block, but only the process that called
      # SimpleCov.start owns the report (same guard SimpleCov uses internally).
      next unless SimpleCov.pid == Process.pid

      resultsets_dir = File.join(base_coverage_dir, "resultsets")

      if Coverage.running?
        # Capture the parent's pre-fork (eager-load) coverage before SimpleCov's own
        # at_exit handler stops tracking.
        parent_result = SimpleCov::Result.new(
          SimpleCov::ResultAdapter.call(Coverage.result),
          command_name: "Minitest (parent)"
        )
        SimpleCov.coverage_dir(File.join(resultsets_dir, "parent"))
        SimpleCov::ResultMerger.store_result(parent_result)
      end

      resultsets = Dir[File.join(resultsets_dir, "*", ".resultset.json")]
      next if resultsets.empty?

      # Restore the canonical coverage dir, then merge every process's resultset into
      # the single report that Codecov and Qlty upload.
      SimpleCov.coverage_dir(base_coverage_dir)
      SimpleCov.collate(resultsets, "rails", ignore_timeout: false) do
        add_filter "/test/"
        add_filter "/config/"
        formatter SimpleCov::Formatter::MultiFormatter.new([
          SimpleCov::Formatter::HTMLFormatter,
          SimpleCov::Formatter::CoberturaFormatter
        ])
      end
    end
  end

  fixtures :all
  include FactoryBot::Syntax::Methods
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
