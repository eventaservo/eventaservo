# frozen_string_literal: true

require "test_helper"

class Observability::RequestMetricsTest < ActiveSupport::TestCase
  # Minimal recorder that captures the calls it receives.
  class FakeRecorder
    attr_reader :counters, :distributions

    def initialize
      @counters = []
      @distributions = []
    end

    def count(name, value:, attributes:)
      @counters << {name: name, value: value, attributes: attributes}
    end

    def distribution(name, value, unit:, attributes:)
      @distributions << {name: name, value: value, unit: unit, attributes: attributes}
    end
  end

  def payload(user_agent: "Mozilla/5.0 (X11; Linux x86_64)", status: 200, duration: 42.5)
    {
      controller: "EventsController",
      action: "index",
      status: status,
      format: :html,
      duration: duration,
      request: Struct.new(:user_agent).new(user_agent)
    }
  end

  test "records a counter and a duration distribution for a finished request" do
    recorder = FakeRecorder.new

    Observability::RequestMetrics.record(payload, metrics: recorder)

    assert_equal 1, recorder.counters.size
    assert_equal "rails.request", recorder.counters.first[:name]
    assert_equal 1, recorder.counters.first[:value]

    assert_equal 1, recorder.distributions.size
    distribution = recorder.distributions.first
    assert_equal "rails.request.duration", distribution[:name]
    assert_in_delta 42.5, distribution[:value]
    assert_equal "millisecond", distribution[:unit]
  end

  test "includes controller, action and status as attributes" do
    recorder = FakeRecorder.new

    Observability::RequestMetrics.record(payload(status: 404), metrics: recorder)

    attributes = recorder.counters.first[:attributes]
    assert_equal "EventsController", attributes[:controller]
    assert_equal "index", attributes[:action]
    assert_equal 404, attributes[:status]
  end

  test "flags automated traffic in the bot attribute" do
    recorder = FakeRecorder.new

    Observability::RequestMetrics.record(
      payload(user_agent: "Googlebot/2.1 (+http://www.google.com/bot.html)"), metrics: recorder
    )

    assert_equal "true", recorder.counters.first[:attributes][:bot]
  end

  test "does not flag a regular browser as bot" do
    recorder = FakeRecorder.new

    Observability::RequestMetrics.record(
      payload(user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"), metrics: recorder
    )

    assert_equal "false", recorder.counters.first[:attributes][:bot]
  end

  test "returns nil instead of raising when the recorder fails" do
    recorder = Object.new
    def recorder.count(*, **)
      raise StandardError, "boom"
    end

    assert_nil Observability::RequestMetrics.record(payload, metrics: recorder)
  end
end
