# frozen_string_literal: true

require "application_system_test_case"

class PrivacyTest < ApplicationSystemTestCase
  test "Viewing the privacy policy" do
    visit "/privateco"
    assert_text "Privateca politiko"

    visit "/license.txt"
    assert_text "Privateca politiko"
  end
end
