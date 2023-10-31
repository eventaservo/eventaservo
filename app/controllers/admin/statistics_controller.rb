module Admin
  class StatisticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @users_registered_by_month = users_registered_by_month

      @event_created_by_month = [
        {name: "Retaj", data: Event.online.where("created_at > ?", 1.year.ago).group_by_month(:created_at).count},
        {name: "Ne retaj", data: Event.not_online.where("created_at > ?", 1.year.ago).group_by_month(:created_at).count}
      ]

      @visitors = Ahoy::Visit.where("started_at >= ?", Date.today - 1.year).group_by_month(:started_at).count
    end

    private

    # @return [Hash] {month: count}
    def users_registered_by_month
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
end
