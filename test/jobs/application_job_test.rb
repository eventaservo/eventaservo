# frozen_string_literal: true

require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class NoopJob < ApplicationJob
    def perform(*)
    end
  end

  test "deserialize normalizes a legacy timezone string" do
    job_data = NoopJob.new.serialize.merge("timezone" => "Asia/Katmandu")

    job = NoopJob.new
    job.deserialize(job_data)

    assert_equal "Asia/Kathmandu", job.timezone
  end

  test "deserialize keeps a valid timezone unchanged" do
    job_data = NoopJob.new.serialize.merge("timezone" => "Europe/Berlin")

    job = NoopJob.new
    job.deserialize(job_data)

    assert_equal "Europe/Berlin", job.timezone
  end

  test "deserialize leaves an unrecognized timezone untouched" do
    job_data = NoopJob.new.serialize.merge("timezone" => "Invalid/Timezone")

    job = NoopJob.new
    job.deserialize(job_data)

    assert_equal "Invalid/Timezone", job.timezone
  end

  test "deserialize is a no-op for a blank serialized timezone" do
    job_data = NoopJob.new.serialize.merge("timezone" => nil)

    job = NoopJob.new

    assert_nothing_raised { job.deserialize(job_data) }
  end
end
