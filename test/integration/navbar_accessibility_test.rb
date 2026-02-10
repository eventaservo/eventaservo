require "test_helper"

class NavbarAccessibilityTest < ActionDispatch::IntegrationTest
  test "navbar tools links have aria-labels" do
    get root_path
    assert_response :success

    # Check for "Subteni" link
    # This should assert that the link HAS the aria-label
    assert_select "a[href='https://liberapay.com/instigo'][aria-label='Subteni']"

    # Check for "Novaĵoj" link
    assert_select "a[href='https://t.me/s/eventaservo'][aria-label='Novaĵoj']"

    # Check for "Pri ni" link
    assert_select "a[href='#{prie_url}'][aria-label='Pri ni']"

    # Check for map toggle link
    # This one is trickier because it depends on cookies, but by default it shows "Vidi kiel mapo"
    assert_select "a[href='#{view_style_url("mapo")}'][aria-label='Vidi kiel mapo']"
  end
end
