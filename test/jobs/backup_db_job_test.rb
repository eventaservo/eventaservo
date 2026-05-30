# frozen_string_literal: true

require "test_helper"

class BackupDbJobTest < ActiveJob::TestCase
  test "enqueues job on backup queue" do
    assert_enqueued_with(job: BackupDbJob, queue: "backup") do
      BackupDbJob.perform_later
    end
  end

  test "calls Backup::Db when performed in production" do
    called = false

    Backup::Db.stub(:new, -> { Object.new.tap { |o| o.define_singleton_method(:call) { called = true } } }) do
      Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
        BackupDbJob.perform_now
      end
    end

    assert called
  end

  test "does not call Backup::Db when not in production" do
    called = false

    Backup::Db.stub(:new, -> { Object.new.tap { |o| o.define_singleton_method(:call) { called = true } } }) do
      BackupDbJob.perform_now
    end

    assert_not called
  end
end
