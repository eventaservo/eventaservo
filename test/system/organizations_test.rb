# frozen_string_literal: true

require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "should create a new organization" do
    user = create(:user, :e2e_test_user)
    login_as(user)

    visit new_organization_path
    assert_no_horizontal_overflow(new_organization_path)

    fill_in "organization_name", with: "Test organization"
    fill_in "organization_short_name", with: "test_org"
    find("#organization_display_flag").click # Disable
    find("#organization_display_flag").click # Enable
    fill_in "organization_url", with: "https://www.eventaservo.org"
    fill_in "organization_youtube", with: "https://youtube.com/eventaservo"
    fill_in "organization_email", with: "test@example.com"
    fill_in "organization_phone", with: "+55 83 99999-9999"
    fill_in "organization_url", with: "http://www.eventaservo.org"
    find("#organization_description").click
    send_keys "Test organization description"
    click_on "Registri"

    assert_text "Organizo sukcese kreita."
  end

  test "organizations index and show render cleanly without horizontal overflow and open webcal modal" do
    organization = organizations(:rotterdam_centre)
    main_org = organizations(:sao_paulo_klubo)
    main_org.update!(major: true, description: "Priskribo de la ĉefa organizo por kontrolo.")
    main_org.logo.attach(
      io: File.open(Rails.root.join("app/assets/images/uea_emblemeto.png")),
      filename: "uea_emblemeto.png",
      content_type: "image/png"
    )
    second_main_org = organizations(:tokyo_society)
    second_main_org.update!(major: true, description: "Priskribo de la dua ĉefa organizo por kontrolo.")
    second_main_org.logo.attach(
      io: File.open(Rails.root.join("app/assets/images/tejo.png")),
      filename: "tejo.png",
      content_type: "image/png"
    )
    user = create(:user, :admin, :e2e_test_user)
    login_as(user)

    visit organizations_path
    assert_selector "#organizations_directory"
    assert_selector "#o_search_results"
    assert_selector "#main_organizations_grid", text: main_org.name
    assert_selector "#main_organizations_grid", text: "Priskribo de la ĉefa organizo"
    assert_selector "#main_organizations_grid", text: second_main_org.name
    assert_selector "#main_organizations_grid img", count: 2
    assert_selector "#o_search_results img", minimum: 2
    assert_no_horizontal_overflow(organizations_path)

    # Debounced live search sends XHR via Rails.ajax and updates #o_search_results via jQuery .html()
    find("#serchi").send_keys("Rotterdam")
    assert_selector "#o_search_results", text: organization.name
    assert_no_selector "#o_search_results", text: main_org.name

    page.current_window.resize_to(1280, 900)
    column_count = evaluate_script(<<~JS)
      getComputedStyle(document.querySelector("#main_organizations_grid")).gridTemplateColumns.trim().split(/\s+/).length
    JS
    assert_equal 2, column_count

    org_path = organization_path(short_name: organization.short_name)
    visit org_path
    assert_selector "#orgTabs"
    assert_selector "#organization_admin_sidebar"
    assert_no_horizontal_overflow(org_path)

    page.current_window.resize_to(393, 852)
    reports_right, card_right = evaluate_script(<<~JS)
      [
        document.querySelector("#reports-tab").getBoundingClientRect().right,
        document.querySelector("#orgTabs").getBoundingClientRect().right
      ]
    JS
    assert_operator reports_right, :<=, card_right,
      "Expected all mobile tabs including Reports badge (#{reports_right}px) to fit inside tab bar (#{card_right}px)"

    find("a[data-dialog-open='webcalModal']").click
    assert_selector "dialog#webcalModal[open]", visible: true
    find("dialog#webcalModal button[data-action='dialog#close']", text: I18n.t("buttons.close")).click
    assert_no_selector "dialog#webcalModal[open]"
  end

  private

  # Asserts that the page at +path+ renders without horizontal overflow across mobile, tablet, and desktop.
  #
  # @param path [String] visited URL path for assertion failure context
  # @return [void]
  def assert_no_horizontal_overflow(path)
    [375, 768, 1280].each do |width|
      page.current_window.resize_to(width, 900)
      scroll_width = evaluate_script("document.documentElement.scrollWidth")
      client_width = evaluate_script("document.documentElement.clientWidth")
      assert_operator scroll_width, :<=, client_width,
        "Expected no horizontal overflow at #{width}px on #{path} (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
    end
  end
end
