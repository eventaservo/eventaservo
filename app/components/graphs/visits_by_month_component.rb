# frozen_string_literal: true

class Graphs::VisitsByMonthComponent < ApplicationComponent
  erb_template <<-ERB
    <div>
      <%= line_chart visits_by_month, title: "Vizitantoj monate" %>
    </div>
  ERB

  def visits_by_month
    Rollup.series("Unique homepage views", interval: "month")
  end
end
