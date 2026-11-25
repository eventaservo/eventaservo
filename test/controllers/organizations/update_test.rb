# frozen_string_literal: true

require "test_helper"

class OrganizationsController::UpdateTest < ActionDispatch::IntegrationTest
  test "renders edit form with validation error when uploading an invalid logo file" do
    organization = organizations(:rotterdam_centre)
    sign_in users(:teacher)

    invalid_file = Rack::Test::UploadedFile.new(
      StringIO.new("%PDF-1.4 fake pdf"),
      "application/pdf",
      false,
      original_filename: "document.pdf"
    )

    patch organization_url(short_name: organization.short_name), params: {
      organization: {
        name: organization.name,
        logo: invalid_file
      }
    }

    assert_response :success
    assert_select ".error-handling", text: /#{Regexp.escape(I18n.t("flash.events.invalid_file_format"))}/
    assert_not organization.reload.logo.attached?
  end
end
