require "rails_helper"

RSpec.describe InternationalEventBadgeComponent, type: :component do
  context "if the event is international" do
    it "renders the badge" do
      event = create(:event, :international_calendar)
      rendered_component = render_inline(described_class.new(event: event))
      expect(rendered_component.css(".badge-success").text).to include("Internacia Evento")
    end
  end

  context "if the event is not international" do
    it "does not render the badge" do
      event = create(:event, international_calendar: false)
      rendered_component = render_inline(described_class.new(event: event))
      expect(rendered_component.css(".badge-success").text).not_to include("Internacia Evento")
    end
  end
end
