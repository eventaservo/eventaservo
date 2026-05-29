class HousekeepingJob < ApplicationJob
  queue_as :low

  def perform
    Housekeeping::CleanAhoy.call
    SolidQueue::Job.clear_finished_in_batches
  end
end
