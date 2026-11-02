# frozen_string_literal: true

require "test_helper"

class Observability::RequestMetricsTest < ActiveSupport::TestCase
  # Minimal metrics recorder that captures the calls it receives, so the test
  # does not depend on Sentry or on the network.
  class FakeRecorder
    # @return [Array<Hash>] recorded counter calls
    attr_reader :counters

    # @return [Array<Hash>] recorded distribution calls
    attr_reader :distributions

    # @return [void]
    def initialize
      @counters = []
      @distributions = []
    end

    # Records a counter call.
    #
    # @param name [String] metric name
    # @param value [Numeric] counter value
    # @param attributes [Hash] metric attributes
    # @return [void]
    def count(name, value:, attributes:)
      @counters << {name: name, value: value, attributes: attributes}
    end

    # Records a distribution call.
    #
    # @param name [String] metric name
    # @param value [Numeric] measured value
    # @param unit [String] unit of the measured value
    # @param attributes [Hash] metric attributes
    # @return [void]
    def distribution(name, value, unit:, attributes:)
      @distributions << {name: name, value: value, unit: unit, attributes: attributes}
    end
  end

  # Builds a payload shaped like the `process_action.action_controller` event.
  #
  # @param user_agent [String] request User-Agent
  # @param status [Integer] response status
  # @param format [Symbol] response format
  # @return [Hash] event payload
  def payload(user_agent: "Mozilla/5.0 (X11; Linux x86_64)", status: 200, format: :html)
    {
      controller: "EventsController",
      action: "index",
      status: status,
      format: format,
      request: Struct.new(:user_agent).new(user_agent)
    }
  end

  # @return [Array(Time, Time)] a start and finish pair 250 ms apart
  def timestamps
    started_at = Time.now.utc
    [started_at, started_at + 0.25]
  end

  test "records a counter and a duration distribution for a finished request" do
    recorder = FakeRecorder.new
    started_at, finished_at = timestamps

    Observability::RequestMetrics.record(
      payload, started_at: started_at, finished_at: finished_at, metrics: recorder
    )

    assert_equal 1, recorder.counters.size
    assert_equal "rails.request", recorder.counters.first[:name]
    assert_equal 1, recorder.counters.first[:value]

    assert_equal 1, recorder.distributions.size
    distribution = recorder.distributions.first
    assert_equal "rails.request.duration", distribution[:name]
    assert_in_delta 250.0, distribution[:value], 1.0
    assert_equal "millisecond", distribution[:unit]
  end

  test "derives latency from the notification timestamps, not from the payload" do
    recorder = FakeRecorder.new
    started_at = Time.now.utc

    Observability::RequestMetrics.record(
      payload, started_at: started_at, finished_at: started_at + 1.5, metrics: recorder
    )

    assert_in_delta 1500.0, recorder.distributions.first[:value], 1.0
  end

  test "subscribes to a real notification and records a non-zero duration" do
    recorder = FakeRecorder.new
    subscription = nil

    Sentry.stub(:initialized?, true) do
      subscription = Observability::RequestMetrics.install!(metrics: recorder)
      ActiveSupport::Notifications.instrument(Observability::RequestMetrics::EVENT, payload) { sleep 0.01 }
    end

    assert_operator recorder.counters.size, :>=, 1
    assert_operator recorder.distributions.map { |d| d[:value] }.max, :>, 0
  ensure
    ActiveSupport::Notifications.unsubscribe(subscription) if subscription
  end

  test "includes controller, action and status as attributes" do
    recorder = FakeRecorder.new
    started_at, finished_at = timestamps

    Observability::RequestMetrics.record(
      payload(status: 404), started_at: started_at, finished_at: finished_at, metrics: recorder
    )

    attributes = recorder.counters.first[:attributes]
    assert_equal "EventsController", attributes[:controller]
    assert_equal "index", attributes[:action]
    assert_equal 404, attributes[:status]
  end

  test "flags automated traffic in the bot attribute" do
    recorder = FakeRecorder.new
    started_at, finished_at = timestamps

    Observability::RequestMetrics.record(
      payload(user_agent: "Googlebot/2.1 (+http://www.google.com/bot.html)"),
      started_at: started_at, finished_at: finished_at, metrics: recorder
    )

    assert_equal "true", recorder.counters.first[:attributes][:bot]
  end

  test "does not flag a regular browser as bot" do
    recorder = FakeRecorder.new
    started_at, finished_at = timestamps

    Observability::RequestMetrics.record(
      payload(user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"),
      started_at: started_at, finished_at: finished_at, metrics: recorder
    )

    assert_equal "false", recorder.counters.first[:attributes][:bot]
  end

  test "returns nil instead of raising when the recorder fails" do
    recorder = Object.new
    def recorder.count(*, **)
      raise StandardError, "boom"
    end
    started_at, finished_at = timestamps

    assert_nil Observability::RequestMetrics.record(
      payload, started_at: started_at, finished_at: finished_at, metrics: recorder
    )
  end
end
