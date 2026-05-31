# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  address      :string
#  city         :string
#  display_flag :boolean          default(TRUE)
#  email        :string
#  logo         :string
#  major        :boolean          default(FALSE)
#  name         :string           not null, indexed
#  official     :boolean          default(FALSE)
#  partner      :boolean          default(FALSE)
#  phone        :string
#  short_name   :string           not null, indexed
#  url          :string
#  youtube      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :integer          default(99999)
#

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "should validate presence of name" do
    organization = Organization.new(short_name: "test")
    assert_not organization.valid?
    assert_includes organization.errors[:name], "devas esti kompletigita"
  end

  test "should validate presence of short_name" do
    organization = Organization.new(name: "Test Organization")
    assert_not organization.valid?
    assert_includes organization.errors[:short_name], "devas esti kompletigita"
  end

  test "validated the format of short_name" do
    # Spaces are now auto-converted to underscores by normalize_short_name
    organization = build(:organization, short_name: "organizo kun spacoj")
    organization.valid?
    assert_equal "organizo_kun_spacoj", organization.short_name

    organization = build(:organization, short_name: "organizo,kun.signoj*divers@aj")
    assert_not organization.valid?
  end

  test "normalizes short_name by replacing spaces with underscores" do
    organization = build(:organization, short_name: "  Nova Organizo  ")
    organization.valid?
    assert_equal "Nova_Organizo", organization.short_name
  end

  test "normalizes short_name by stripping leading and trailing whitespace" do
    organization = build(:organization, short_name: "  UEA  ")
    organization.valid?
    assert_equal "UEA", organization.short_name
  end

  test "should have one attached logo" do
    organization = Organization.new
    assert_respond_to organization, :logo
  end

  test "should have rich text description" do
    organization = Organization.new
    assert_respond_to organization, :description
  end

  test "should have many organization_users" do
    organization = Organization.new
    assert_respond_to organization, :organization_users
  end

  test "should have many organization_events" do
    organization = Organization.new
    assert_respond_to organization, :organization_events
  end

  test "should have many users through organization_users" do
    organization = Organization.new
    assert_respond_to organization, :users
  end

  test "should have many uzantoj" do
    organization = Organization.new
    assert_respond_to organization, :uzantoj
  end

  test "should have many events through organization_events" do
    organization = Organization.new
    assert_respond_to organization, :events
  end

  test "should have many eventoj" do
    organization = Organization.new
    assert_respond_to organization, :eventoj
  end

  test "should belong to country" do
    organization = Organization.new
    assert_respond_to organization, :country
  end
end
