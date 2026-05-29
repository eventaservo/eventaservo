# frozen_string_literal: true

require "test_helper"

class EventRedirectsIntegrationTest < ActionDispatch::IntegrationTest
  test "should redirect the old short_url to the new one" do
    event = create(:event)
    old_short_url = event.short_url

    get "/e/#{old_short_url}"
    assert_response :success
    assert_equal "/e/#{old_short_url}", path

    event.update(short_url: "new_short_url")

    event_redirection = EventRedirection.find_by(old_short_url: old_short_url)
    get "/e/#{old_short_url}"
    assert_equal 1, event_redirection.reload.hits
    assert_response :redirect
    assert_redirected_to "/e/new_short_url"

    follow_redirect!
    assert_equal "/e/new_short_url", path
  end
end
