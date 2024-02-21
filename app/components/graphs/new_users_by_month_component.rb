# frozen_string_literal: true

class Graphs::NewUsersByMonthComponent < ApplicationComponent
  erb_template <<-ERB
    <div>
      <%= line_chart [
          { name: "Novaj", data: new_users_by_month},
          { name: "Sumo", data: total_users_by_month }
        ], title: "Novaj uzantoj monate" %>
    </div>
  ERB

  def new_users_by_month
    Rollup.where(time: time_range).series("New users by month", interval: "month")
  end

  def total_users_by_month
    total = 0
    Rollup.where(time: time_range).series("New users by month", interval: "month").transform_values { |v|
      total += v
      total
    }
  end

  private

  def time_range
    (Date.today - 12.months)..Date.today
  end
end
