# frozen_string_literal: true

require "test_helper"

class NavbarAccessibilityTest < ActionDispatch::IntegrationTest
  test "navbar icon-only links have aria-labels" do
    get root_path
    assert_response :success

    # Support (Liberapay)
    assert_select "a[href='https://liberapay.com/instigo']" do |links|
      assert_not_empty links
      desktop_link = links.find { |link| link.parent["class"]&.include?("d-lg-block") }
      assert desktop_link, "Could not find desktop Support link"

      assert desktop_link["aria-label"].present?, "Desktop Support link missing aria-label"
      assert_equal "Subteni", desktop_link["aria-label"]
    end

    # News (Telegram)
    assert_select "a[href='https://t.me/s/eventaservo']" do |links|
      assert_not_empty links
      desktop_link = links.find { |link| link.parent["class"]&.include?("d-lg-block") }
      assert desktop_link, "Could not find desktop News link"

      assert desktop_link["aria-label"].present?, "Desktop News link missing aria-label"
      assert_equal "Novaĵoj", desktop_link["aria-label"]
    end

    # About Us
    # Use contains match because navbar uses url (absolute) and footer uses path (relative)
    assert_select "a[href*='#{prie_path}']" do |links|
      assert_not_empty links
      desktop_link = links.find { |link| link.parent["class"]&.include?("d-lg-block") }
      assert desktop_link, "Could not find desktop About Us link"

      assert desktop_link["aria-label"].present?, "Desktop About Us link missing aria-label"
      assert_equal "Pri ni", desktop_link["aria-label"]
    end

    # Map Toggle
    # Default cookies[:vidmaniero] is nil, so it should show "Vidi kiel mapo" (link to 'mapo')
    assert_select "a[href*='/v/mapo']" do |links|
      assert_not_empty links
      desktop_link = links.find { |link| link.parent["class"]&.include?("d-lg-block") }
      assert desktop_link, "Could not find desktop Map Toggle link"

      assert desktop_link["aria-label"].present?, "Desktop Map Toggle link missing aria-label"
      assert_equal "Vidi kiel mapo", desktop_link["aria-label"]
    end
  end

  test "navbar map toggle link has aria-label when map is active" do
    # Simulate cookie being set
    get root_path, headers: { "HTTP_COOKIE" => "vidmaniero=mapo" }

    assert_select "a[href*='/v/kalendaro']" do |links|
      assert_not_empty links
      desktop_link = links.find { |link| link.parent["class"]&.include?("d-lg-block") }
      assert desktop_link, "Could not find desktop Map Close link"

      assert desktop_link["aria-label"].present?, "Desktop Map Close link missing aria-label"
      assert_equal "Fermi la mapon", desktop_link["aria-label"]
    end
  end
end
