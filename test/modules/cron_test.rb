# frozen_string_literal: true

require "test_helper"

class CronTest < ActiveJob::TestCase
  test "schedule a Worker Heartbeat" do
    assert_enqueued_with(job: WorkerHeartbeatJob) do
      Cron.worker_heartbeat
    end
  end
end
