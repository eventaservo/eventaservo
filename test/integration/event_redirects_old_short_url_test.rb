require "test_helper"

class EventRedirectsOldShortUrlTest < ActionDispatch::IntegrationTest
  # When a user edits an event and change the short_url, the old short_url should redirect to the new one
  # and the EventRedirection's hit must be incremented by 1
  def test_event_redirection_by_short_url
    host! "localhost:3000"

    event = create(:event)
    old_short_url = event.short_url

    get "/e/#{old_short_url}"
    assert_response :success
    assert_equal "/e/#{old_short_url}", path

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
