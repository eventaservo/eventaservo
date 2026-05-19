class Graphs::FilterByCategoryComponent < ApplicationComponent
  erb_template <<-ERB
    <div>
      <%= line_chart series, title:, library: %>
    </div>
  ERB

  def title
    "Use of category filters"
  end

  def series
    series = Rollup.multi_series("Filter by category", interval: "month")
    series.each do |s|
      s[:name] = s[:dimensions]["name"]
    end
  end

  def library
    {
      subtitle: {
        text: "Clicks on category filter label on homepage"
      }
    }
  end
end
