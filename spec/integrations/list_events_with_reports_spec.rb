require "rails_helper"

RSpec.describe "List events with Reports", type: :request do
  it "list only events with reports" do
    event_without_report = create(:event)
    event_with_report = create(:event_report).event

    get reports_url
    expect(response).to have_http_status(:success)
    assert_select "div.lead", text: "Eventoj kun raportoj"
    assert_select "a.link-blue", text: event_with_report.title
    assert_select "a.link-blue", {count: 0, text: event_without_report.title}
  end
end
