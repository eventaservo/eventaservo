require "test_helper"

class VideoController::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    video = videos(:rails_conference_video)
    get video_url
    assert_response :success
    assert_match video.title, response.body
  end

  test "video component organization name xss" do
    event = events(:valid_event)

    # Create malicious organization
    org = Organization.create!(
      name: "<script>alert('xss')</script>",
      short_name: "hacker",
      description: "Malicious organization",
      country: countries(:brazil)
    )

    event.organizations << org

    Video.create!(
      evento: event,
      url: "https://example.com/video",
      title: "Malicious Video",
      description: "Video desc"
    )

    get video_url
    assert_response :success
    assert_no_match(/<script>alert\('xss'\)<\/script>/, response.body)
    assert_match(/&lt;script&gt;alert\(&#39;xss&#39;\)&lt;\/script&gt;/, response.body)
  end
end
