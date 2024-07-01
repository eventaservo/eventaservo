class HousekeepingJob < ApplicationJob
  queue_as :low

  def perform
    Housekeeping::CleanAhoy.call
  end
end
