# frozen_string_literal: true

require "test_helper"

class Organization::SearchTest < ActiveSupport::TestCase
  test "serchi finds matching organizations by name or short_name" do
    create(:organization, name: "Esperanto Asocio de Brazilo", short_name: "EAB")
    create(:organization, name: "Universala Esperanto-Asocio", short_name: "UEA")

    results = Organization.serchi("Brazilo")
    assert_includes results.map(&:short_name), "EAB"
    refute_includes results.map(&:short_name), "UEA"

    results = Organization.serchi("UEA")
    assert_includes results.map(&:short_name), "UEA"
    refute_includes results.map(&:short_name), "EAB"
  end

  test "serchi returns all organizations when the query is nil" do
    create(:organization, name: "Esperanto Asocio de Brazilo", short_name: "EAB")
    create(:organization, name: "Universala Esperanto-Asocio", short_name: "UEA")

    results = Organization.serchi(nil)
    assert_equal 2, results.count
    assert_includes results.map(&:short_name), "EAB"
    assert_includes results.map(&:short_name), "UEA"
  end

  test "serchi returns all organizations when the query is blank" do
    create(:organization, name: "Esperanto Asocio de Brazilo", short_name: "EAB")
    create(:organization, name: "Universala Esperanto-Asocio", short_name: "UEA")

    results = Organization.serchi("   ")
    assert_equal 2, results.count
    assert_includes results.map(&:short_name), "EAB"
    assert_includes results.map(&:short_name), "UEA"
  end
end
