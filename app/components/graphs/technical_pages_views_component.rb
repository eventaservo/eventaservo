class Graphs::TechnicalPagesViewsComponent < ApplicationComponent
  erb_template <<-ERB
    <div>
      <%= line_chart series, title: %>
    </div>
  ERB

  def title
    "Technical pages views"
  end

  def series
    series = Rollup.multi_series("Techinical page views", interval: "month")
    series.each do |s|
      s[:name] = s[:dimensions]["name"]
    end
  end
end
