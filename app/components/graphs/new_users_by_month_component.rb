# frozen_string_literal: true

class Graphs::NewUsersByMonthComponent < ApplicationComponent
  erb_template <<-ERB
    <div>
      <%= line_chart [
          { name: "New", data: new_users_by_month},
          { name: "Total", data: total_users_by_month }
        ], title: "Novaj uzantoj monate" %>
    </div>
  ERB

  def new_users_by_month
    Rollup.series("New users by month", interval: "month")
  end

  def total_users_by_month
    total = 0
    Rollup.series("New users by month", interval: "month").transform_values { |v| total += v; total }
  end
end
