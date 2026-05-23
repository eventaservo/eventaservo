# frozen_string_literal: true

require "test_helper"

class WorkerHeartbeatJobTest < ActiveJob::TestCase
  test "enqueues job with low priority" do
    assert_enqueued_with(job: WorkerHeartbeatJob, queue: "low") do
      WorkerHeartbeatJob.perform_later
    end
  end

  test "returns early in development environment" do
    Rails.env.stub(:development?, true) do
      HTTParty.stub(:get, -> { flunk "should not be called" }) do
        WorkerHeartbeatJob.perform_now
      end
    end

    assert true
  end

  test "calls HTTParty.get with the heartbeat URL" do
    url = "https://example.com/heartbeat"
    called = false

    Rails.application.credentials.stub(:dig, url, [:better_uptime, :background_worker_heartbeat]) do
      HTTParty.stub(:get, ->(arg) {
        called = true
        assert_equal url, arg
      }) do
        WorkerHeartbeatJob.perform_now
      end
    end

    assert called
  end
end
