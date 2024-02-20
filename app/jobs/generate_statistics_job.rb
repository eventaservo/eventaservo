class GenerateStatisticsJob < ApplicationJob
  queue_as :low

  def perform
    User.rollup("New users by month", interval: "month")
    Ahoy::Event.where(name: "Homepage").joins(:visit).rollup("Unique homepage views", interval: "month") { |r| r.distinct.count(:visitor_token) }
  end
end
