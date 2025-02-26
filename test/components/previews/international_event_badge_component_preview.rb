class InternationalEventBadgeComponentPreview < ViewComponent::Preview
  layout "component_preview"

  def default
    event = Event.new(international_calendar: true)
    render(InternationalEventBadgeComponent.new(event: event))
  end
end
