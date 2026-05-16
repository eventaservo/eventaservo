require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "error_handling escapes malicious error messages" do
    event = Event.new(title: "<script>alert('xss')</script>")
    event.valid? # trigger validations
    # Manually add an error that mimics user input
    event.errors.add(:title, "is invalid: <script>alert('xss')</script>")

    html = error_handling(event)

    assert_no_match(/<script>alert\('xss'\)<\/script>/, html)
    assert_match(/&lt;script&gt;alert\(&#39;xss&#39;\)&lt;\/script&gt;/, html)
  end
end
