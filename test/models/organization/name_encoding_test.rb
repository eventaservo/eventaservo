# frozen_string_literal: true

require "test_helper"

class Organization::NameEncodingTest < ActiveSupport::TestCase
  test "returns name unchanged when encoding is already UTF-8" do
    organization = build(:organization, name: "Esperanto Asocio")

    assert_equal Encoding::UTF_8, organization.name.encoding
    assert_equal "Esperanto Asocio", organization.name
  end

  test "normalizes BINARY encoding to UTF-8 on read" do
    organization = build(:organization)
    organization.name = "AERĴ".force_encoding(Encoding::BINARY)

    assert_equal "AERĴ", organization.name
    assert_equal Encoding::UTF_8, organization.name.encoding
  end

  test "scrubs invalid byte sequences when normalizing from BINARY" do
    organization = build(:organization)
    organization.name = "\xFF".force_encoding(Encoding::BINARY)

    assert organization.name.encoding == Encoding::UTF_8
    assert_equal "\uFFFD", organization.name
  end
end
