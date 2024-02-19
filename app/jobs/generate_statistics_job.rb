class GenerateStatisticsJob < ApplicationJob
  queue_as :low

  def perform
    User.rollup("New users by month", interval: "month")
  end
end
