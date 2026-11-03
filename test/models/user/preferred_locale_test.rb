# frozen_string_literal: true

require "test_helper"

class User::PreferredLocaleTest < ActiveSupport::TestCase
  test "returns default locale when user has no explicit locale" do
    user = users(:user)
    user.mailings = {}

    assert_equal :eo, user.preferred_locale
  end

  test "returns english when preferred locale is en" do
    user = users(:user)
    user.mailings = {"locale" => "en"}

    assert_equal :en, user.preferred_locale
  end

  test "returns portuguese when preferred locale is pt_BR" do
    user = users(:user)
    user.mailings = {"locale" => "pt_BR"}

    assert_equal :pt_BR, user.preferred_locale
  end

  test "falls back to default locale when locale in mailings is unsupported" do
    user = users(:user)
    user.mailings = {"locale" => "unsupported_locale"}

    assert_equal :eo, user.preferred_locale
  end
end
