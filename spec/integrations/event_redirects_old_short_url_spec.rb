require "rails_helper"

RSpec.describe "Event Redirects", type: :request do
  # When a user edits an event and change the short_url, the old short_url should redirect to the new one
  # and the EventRedirection's hit must be incremented by 1
  it "should redirect the old short_url to the new one" do
    event = create(:event)
    old_short_url = event.short_url

    get "/e/#{old_short_url}"
    expect(response).to have_http_status(:success)
    expect(path).to eq("/e/#{old_short_url}")

    # Now, update the event's short_url
    event.update(short_url: "new_short_url")

    # and check that the old short_url redirects to the new one
    # and the EventRedirection's hit is incremented by 1

    event_redirection = EventRedirection.find_by(old_short_url: old_short_url)
    get "/e/#{old_short_url}"
    assert_equal 1, event_redirection.reload.hits
    assert_response :redirect
    assert_redirected_to "/e/new_short_url"

    follow_redirect!
    assert_equal "/e/new_short_url", path
  end
end
