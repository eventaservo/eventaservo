require "test_helper"

class AccessibilityTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "organization form has accessible file input label" do
    get new_organization_path
    assert_response :success

    # Check for file input
    assert_select "input[type=file][id=organization_logo]", 1

    # Check for label associated with file input
    assert_select "label[for=organization_logo]", 1, "Organization logo file input is missing a label"
  end

  test "video form has accessible file input label" do
    # Ensure country exists for event factory if needed
    Country.find_by(code: "br") || Country.create!(code: "br", name_eo: "Brazilo", name_en: "Brazil")

    event = create(:event, user: @user)
    get event_new_video_path(event_code: event.code)
    assert_response :success

    # Check for file input
    # With form_with and no scope, id might be just "image"
    assert_select "input[type=file][name=image]", 1

    # Check for label associated with file input
    assert_select "label[for=image]", 1, "Video image file input is missing a label"
  end

  test "user registration form has accessible file input label" do
    get edit_user_registration_path
    assert_response :success

    # Check for file input
    assert_select "input[type=file][id=user_picture]", 1

    # Check for label associated with file input
    assert_select "label[for=user_picture]", 1, "User picture file input is missing a label"
  end
end
