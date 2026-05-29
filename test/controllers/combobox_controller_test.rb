# frozen_string_literal: true

require "test_helper"

class ComboboxControllerTest < ActionDispatch::IntegrationTest
  test "users_with_username returns matching users" do
    create(:user, name: "Zamenhof", username: "zamenhof")
    create(:user, name: "John Doe", username: "john")

    get combobox_users_with_username_url(q: "Zam", format: :turbo_stream)

    assert_response :success
    assert_includes response.body, "Zamenhof"
    assert_not_includes response.body, "John Doe"
  end

  test "users_with_username returns empty for blank query" do
    create(:user, name: "Zamenhof")

    get combobox_users_with_username_url(q: "", format: :turbo_stream)

    assert_response :success
    assert_not_includes response.body, "Zamenhof"
  end
end
