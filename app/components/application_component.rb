class ApplicationComponent < ViewComponent::Base
  # Trick to make ChartKick compatible with ViewComponents
  def chartkick_chart_id
    self.class.name.underscore.dasherize.gsub("/", "--")
  end

  alias_method :orig_chartkick_chart, :chartkick_chart

  def chartkick_chart(klass, data_source, **options)
    opts = options.merge(id: chartkick_chart_id)
    orig_chartkick_chart klass, data_source, **opts
  end
end
