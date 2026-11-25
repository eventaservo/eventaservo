# frozen_string_literal: true

require "test_helper"

class Organization::ValidationTest < ActiveSupport::TestCase
  test "accepts PNG logo" do
    organization = organizations(:rotterdam_centre)
    organization.logo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )

    assert organization.valid?
  end

  test "accepts SVG logo" do
    organization = organizations(:rotterdam_centre)
    organization.logo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/logo.svg")),
      filename: "logo.svg",
      content_type: "image/svg+xml"
    )

    assert organization.valid?
  end

  test "rejects non-image logo" do
    organization = organizations(:rotterdam_centre)
    organization.logo.attach(
      io: StringIO.new("not an image"),
      filename: "document.pdf",
      content_type: "application/pdf"
    )

    assert_not organization.valid?
    assert_includes organization.errors[:logo], I18n.t("flash.events.invalid_file_format")
  end
end
