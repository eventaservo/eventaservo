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
    sql = <<~SQL
      WITH CumulativeCounts AS (
          SELECT DISTINCT
              TO_CHAR(created_at, 'YYYY-MM') AS month,
              SUM(1) OVER (ORDER BY TO_CHAR(created_at, 'YYYY-MM')) AS cumulative_count
          FROM users
      )
      SELECT month, cumulative_count
      FROM CumulativeCounts
      ORDER BY month DESC
      LIMIT 12;
    SQL

    array = ActiveRecord::Base.connection.execute(sql).to_a.reverse

    hash = {}
    array.each do |a|
      month = Date.parse(a["month"] + "-01")
      count = a["cumulative_count"]
      hash[month] = count
    end

    hash
  end
end
