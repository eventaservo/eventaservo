# frozen_string_literal: true

require "json"
require "test_helper"
require_relative "../../lib/bootstrap_usage"

module DesignSystem
  # Fails when Bootstrap usage grows in a directory. Decreases are allowed and
  # can be ratcheted into the baseline with `bin/bootstrap-usage --write`.
  class BootstrapUsageTest < ActiveSupport::TestCase
    BASELINE = JSON.parse(Rails.root.join("config/bootstrap_usage_baseline.json").read)

    test "does not increase Bootstrap usage" do
      BootstrapUsage.counts.each do |dir, counts|
        counts.each do |pattern, count|
          baseline = BASELINE.dig(dir, pattern.to_s) || 0

          assert_operator count, :<=, baseline,
            "#{dir} #{pattern} increased from #{baseline} to #{count}; " \
            "update the baseline only after a deliberate migration."
        end
      end
    end
  end
end
