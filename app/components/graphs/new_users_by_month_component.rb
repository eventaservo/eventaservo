# frozen_string_literal: true

class Graphs::NewUsersByMonthComponent < ApplicationComponent
  def initialize(range: nil)
    @range = range || default_range
  end

  erb_template <<-ERB
    <div>
      <%= line_chart [
          { name: "Novaj", data: new_users_by_month},
          { name: "Sumo", data: total_users_by_month }
        ], title: "Novaj uzantoj monate" %>
    </div>
  ERB

  def new_users_by_month
    Rollup.where(time: @range).series("New users by month", interval: "month")
  end

  def total_users_by_month
    total = User.where("created_at < ?", @range.first.beginning_of_month).count
    Rollup.where(time: @range).series("New users by month", interval: "month").transform_values { |v|
      total += v
      total
    }
  end

  private

  def default_range
    (Date.today - 11.months).beginning_of_month..Date.today.end_of_month
  end
end
