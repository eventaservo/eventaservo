# frozen_string_literal: true

require "test_helper"

class Users::AdminSearchQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin_user)
    @teacher = users(:teacher)
  end

  test "returns active users ordered by name by default" do
    @admin.update_column(:disabled, true)

    result = Users::AdminSearchQuery.new.call

    assert_includes result, @user
    assert_not_includes result, @admin
    assert_equal result.map(&:name).sort, result.map(&:name)
  end

  test "filters disabled users when scope is disabled" do
    @admin.update_column(:disabled, true)

    result = Users::AdminSearchQuery.new(scope: "disabled").call

    assert_includes result, @admin
    assert_not_includes result, @user
  end

  test "filters abandoned users when scope is abandoned" do
    @user.update_column(:last_sign_in_at, 3.years.ago)
    @admin.update_column(:last_sign_in_at, 1.month.ago)

    result = Users::AdminSearchQuery.new(scope: "abandoned").call

    assert_includes result, @user
    assert_not_includes result, @admin
  end

  test "filters unconfirmed users when scope is not_confirmed" do
    @user.update_column(:confirmed_at, nil)

    result = Users::AdminSearchQuery.new(scope: "not_confirmed").call

    assert_includes result, @user
    assert_not_includes result, @admin
  end

  test "filters by name case-insensitively and escapes LIKE metacharacters" do
    result = Users::AdminSearchQuery.new(name: "ana instruisto").call
    assert_includes result, @teacher
    assert_not_includes result, @user

    escaped_result = Users::AdminSearchQuery.new(name: "Ana%Instruisto").call
    assert_not_includes escaped_result, @teacher
  end

  test "filters by email" do
    result = Users::AdminSearchQuery.new(email: "standard@user").call

    assert_includes result, @user
    assert_not_includes result, @admin
  end

  test "filters by username" do
    result = Users::AdminSearchQuery.new(username: "admin_user").call

    assert_includes result, @admin
    assert_not_includes result, @user
  end

  test "filters by country_id" do
    result = Users::AdminSearchQuery.new(country_id: @teacher.country_id).call

    assert_includes result, @teacher
    assert_not_includes result, @user
  end

  test "combines scope and multiple filters" do
    @teacher.update_column(:disabled, true)

    result = Users::AdminSearchQuery.new(
      scope: "disabled",
      name: "Ana",
      country_id: @teacher.country_id
    ).call

    assert_equal [@teacher], result.to_a
  end
end
