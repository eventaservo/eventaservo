class GenerateStatisticsJob < ApplicationJob
  queue_as :low

  def perform
    User.rollup("New users by month", interval: "month")
    Ahoy::Event.where(name: "Homepage").joins(:visit).rollup("Unique homepage views", interval: "month") { |r| r.distinct.count(:visitor_token) }
    filter_event_statistics
  end

  private

  def filter_event_statistics
    categories = [
      "Filter category by Alia",
      "Filter category by Internacia",
      "Filter category by Kurso",
      "Filter category by Loka",
      "Filter by one-day-event",
      "Filter by multi-day-event"
    ]
    Ahoy::Event.where(name: categories).group(:name).rollup("Filter by category", interval: "month")
    Ahoy::Event.where(name: categories).destroy_all
  end
end
